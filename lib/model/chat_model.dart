import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:link2bd/model/memory.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

typedef ListCallback = void Function(List<ChatMessage>);

class ChatModel{
  String lastID = 'none';
  final String messageToken;
  bool keepUpdating = true;
  ListCallback bulkLoad;
  final _chatController = BehaviorSubject<ChatMessage>();

  Stream<ChatMessage> get chatStream => _chatController.stream;
  StreamSink<ChatMessage> get chatSink => _chatController.sink;

  ChatModel({required this.messageToken, required this.bulkLoad}){
    update();
  }

  Future<void> update() async{
    if(keepUpdating){
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'token' : memory.token,
        'message_token' : messageToken,
        'last_id' : lastID
      });
      Response response = await dio.post(
        'https://linktobd.com/appapi/get_messages',
        data: formData,
      );
      var respond = response.data as List;
      if(respond.isNotEmpty){
        if(respond.length > 5){
          List<ChatMessage> newMessages = [];
          late ChatMessage lastMessage;
          for(var message in respond){
            ChatMessage chatMessage = ChatMessage(
                id: message['id'].toString(),
                type: 'new',
                uniqueId: message['uniqueId'].toString(),
                sender: message['sender'].toString(),
                message: message['message'].toString(),
                localTime: message['local_time'].toString(),
                sent: true
            );
            lastID = message['id'].toString();
            lastMessage = chatMessage;
            newMessages.add(chatMessage);
          }
          bulkLoad(newMessages);
          lastMessage.type = 'update';
          _chatController.add(lastMessage);
        }else{
          for(var message in respond){
            ChatMessage chatMessage = ChatMessage(
                id: message['id'].toString(),
                type: 'new',
                uniqueId: message['uniqueId'].toString(),
                sender: message['sender'].toString(),
                message: message['message'].toString(),
                localTime: message['local_time'].toString(),
                sent: true
            );
            await Future.delayed(const Duration(milliseconds: 100));
            lastID = message['id'].toString();
            _chatController.add(chatMessage);
          }
        }
      }
    }
    await Future.delayed(const Duration(seconds: 2));
    update();
  }

  Future<void> addNew(String message) async{
    if(message.trim() != ''){
      keepUpdating = false;
      Uuid uuid = Uuid();
      String uniqueId = uuid.v1();
      ChatMessage chatMessage = ChatMessage(id: '', type: 'new', uniqueId: uniqueId, sender: 'user', message: message, localTime: '', sent: false);
      _chatController.add(chatMessage);
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'token' : memory.token,
        'message_token' : messageToken,
        'message' : message,
        'uuid' : uniqueId
      });
      Response response = await dio.post(
        'https://linktobd.com/appapi/chat_add_message',
        data: formData,
      );
      var respond = response.data;
      if(respond['success'].toString() == 'yes'){
        chatMessage.type = 'update';
        chatMessage.sent = true;
        chatMessage.localTime = respond['local_time'].toString();
        chatMessage.id = respond['id'].toString();
        _chatController.add(chatMessage);
        lastID = chatMessage.id.toString();
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

  ChatMessage({required this.id, required this. type, required this.uniqueId, required this.sender, required this.message, required this.localTime, required this.sent});
}
