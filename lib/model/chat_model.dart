import 'dart:async';
import 'package:dio/dio.dart';
import 'package:linktobd/model/db_manager.dart';
import 'package:linktobd/model/memory.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

typedef ListCallback = void Function(List<ChatMessage>);

class ChatModel {
  String lastID = 'none';
  final String messageToken;
  bool keepUpdating = true;
  ListCallback bulkLoad;
  final _chatController = BehaviorSubject<ChatMessage>();

  Stream<ChatMessage> get chatStream => _chatController.stream;
  StreamSink<ChatMessage> get chatSink => _chatController.sink;

  DbTable chatTable = DbTable(
    tableName: 'chat_messages_local',
    columns: [
      'id','api_db_id','unique_id','message',
      'sender','local_time','message_token','sent'
    ],
  );

  DbManager dbManager = DbManager(); // Create an instance of DbManager

  ChatModel({required this.messageToken, required this.bulkLoad}) {
    initDatabase(); // Initialize DB and load messages
    update(); // Start listening for new messages
  }

  closeChat(){
    _chatController.close();
  }

  // Initialize the database, ensure the chat table exists, and load offline messages
  Future<void> initDatabase() async {
    await dbManager.ensureTableExists(chatTable);

    // Load previous messages from local database
    List<Map<String, dynamic>> storedMessages = await dbManager.getData(
      'chat_messages_local',
      'id',
      where: 'message_token = ?',
      whereArgs: [messageToken],
      orderDirection: 'DESC', // Fetch older messages first
    );

    List<ChatMessage> loadedMessages = storedMessages.map((row) {
      return ChatMessage(
        id: row['id'].toString(),
        type: 'new',
        uniqueId: row['unique_id'].toString(),
        sender: row['sender'].toString(),
        message: row['message'].toString(),
        localTime: row['local_time'].toString(),
        sent: int.tryParse(row['sent'].toString()) == 1,
        apiDbId: row['api_db_id'].toString()
      );
    }).toList();

    bulkLoad(loadedMessages);

    if (loadedMessages.isNotEmpty) {
      lastID = loadedMessages.last.apiDbId; // Set the lastID to the latest message ID
    }
  }



  // Store a message in the local database
  Future<void> storeMessageInDb(ChatMessage chatMessage) async {
    Map<String, dynamic> messageRow = {
      'id': chatMessage.id,
      'unique_id': chatMessage.uniqueId,
      'message': chatMessage.message,
      'sender': chatMessage.sender,
      'local_time': chatMessage.localTime,
      'message_token': messageToken,
      'sent': chatMessage.sent ? 1 : 0,
      'api_db_id' : chatMessage.apiDbId
    };

    await dbManager.insertRows(DbTable(
      tableName: 'chat_messages_local',
      columns: chatTable.columns,
      rows: [messageRow],
    ));
  }

  // Fetch new messages from the server
  Future<void> update() async {
    if (keepUpdating) {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'token': memory.token,
        'message_token': messageToken,
        'last_id': lastID
      });
      print('lastId $lastID');
      Response response = await dio.post(
        'https://linktobd.com/appapi/get_messages',
        data: formData,
      );
      var respond = response.data as List;

      if (respond.isNotEmpty) {
        List<ChatMessage> newMessages = [];
        for (var message in respond) {
          ChatMessage chatMessage = ChatMessage(
            id: message['id'].toString(),
            type: 'new',
            uniqueId: message['uniqueId'].toString(),
            sender: message['sender'].toString(),
            message: message['message'].toString(),
            localTime: message['local_time'].toString(),
            sent: true,
            apiDbId: message['id']
          );
          lastID = message['id'].toString();
          newMessages.add(chatMessage);

          // Store the message in the database
          await storeMessageInDb(chatMessage);
        }

        bulkLoad(newMessages);
        _chatController.add(newMessages.last); // Update the stream
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    update(); // Keep polling for new messages
  }

  // Send a new message and store it locally
  Future<void> addNew(String message) async {
    if (message.trim() != '') {
      keepUpdating = false;
      Uuid uuid = Uuid();
      String uniqueId = uuid.v1();
      ChatMessage chatMessage = ChatMessage(
        id: '',
        type: 'new',
        uniqueId: uniqueId,
        sender: 'user',
        message: message,
        localTime: '',
        sent: false,
        apiDbId: '',
      );

      _chatController.add(chatMessage);

      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'token': memory.token,
        'message_token': messageToken,
        'message': message,
        'uuid': uniqueId
      });
      Response response = await dio.post(
        'https://linktobd.com/appapi/chat_add_message',
        data: formData,
      );
      var respond = response.data;
      if (respond['success'].toString() == 'yes') {
        chatMessage.type = 'update';
        chatMessage.sent = true;
        chatMessage.localTime = respond['local_time'].toString();
        chatMessage.apiDbId = respond['id'].toString();
        _chatController.add(chatMessage);
        lastID = chatMessage.apiDbId.toString();

        // Store the sent message in the database
        await storeMessageInDb(chatMessage);
      }
      keepUpdating = true;
    }
  }
}


class ChatMessage {
  String id;
  String type; //update || new
  String uniqueId;
  String sender;
  String message;
  String localTime;
  bool sent;
  String apiDbId;

  ChatMessage({required this.id, required this. type, required this.uniqueId, required this.sender, required this.message, required this.localTime, required this.sent, required this.apiDbId});
}