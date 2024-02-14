import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/chat_model.dart';
import 'package:link2bd/model/memory.dart';

class PrivateChat extends StatefulWidget {
  final String chatPartnerName;
  final String chatPartnerImage;
  final String username;

  const PrivateChat({
    Key? key,
    required this.chatPartnerName,
    required this.chatPartnerImage,
    required this.username
  }) : super(key: key);

  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {
  List<ChatMessage> messages = [];
  final TextEditingController messageController = TextEditingController();
  String messageToken = '';
  late ChatModel chatModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.username != 'Unavailable'){
      startEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatPartnerName),
        actions: [
          // Displaying chat partner image in app bar
          CircleAvatar(
            backgroundImage: NetworkImage(widget.chatPartnerImage),
            radius: 20,
          ),
        ],
      ),
      body: (messageToken == '') ? Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatModel.chatStream,
              builder: (context, snapshot) {
                if(snapshot.hasError){
                  print(snapshot.error.toString());
                  return Text(snapshot.error.toString());
                }else if(snapshot.hasData){
                  ChatMessage incoming = snapshot.data as ChatMessage;
                  if(incoming.type == 'new'){
                    messages.insert(0, incoming);
                  }else{
                    updateMessageByUniqueId(incoming.uniqueId, incoming.localTime);
                  }
                  return (messages.isNotEmpty) ?  ListView.builder(
                    reverse: true, // New messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return messageWidget(message);
                    },
                  ) : Container();
                }else{
                  return Container();
                }

              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: (){
                    chatModel.addNew(messageController.text);
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget messageWidget(ChatMessage message) {
    bool isUserMessage = message.sender == 'user';
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) // Chat partner's messages at start
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatPartnerImage),
              radius: 15,
            ),
          Flexible( // Make Flexible a direct child of the Row
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: isUserMessage ? (message.sent ? Colors.blue : Colors.grey[500]) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                      softWrap: true, // Ensure the text wraps
                      overflow: TextOverflow.visible, // Handle overflow visibly
                    ),
                    // Text(
                    //   message.localTime,
                    //   style: TextStyle(color: Colors.grey, fontSize: 5),
                    //   textAlign: TextAlign.right,
                    // )
                  ],
                ),
              ),
            ),
          ),
          if (isUserMessage) // User's messages at end
            CircleAvatar(
              backgroundImage: NetworkImage(memory.photoURL),
              radius: 15,
            ),
        ],
      ),
    );
  }




  Future<void> startEngine() async{
    Dio dio = Dio();
    FormData formData = FormData.fromMap({'token' : memory.token, 'username' : widget.username});
    Response response = await dio.post(
      'https://linktobd.com/appapi/get_connection_token',
      data: formData,
    );

    var respond = response.data;
    if(respond['success'].toString() == 'yes'){
      messageToken = respond['token'].toString();
    }
    chatModel = ChatModel(messageToken: messageToken, bulkLoad: (List<ChatMessage> newMessages){
      for(ChatMessage newMessage in newMessages){
        messages.insert(0, newMessage);
      }
    });
    await Future.delayed(Duration(milliseconds: 10));
    setState(() {
      messageToken;
      chatModel;
    });
  }


  void updateMessageByUniqueId(String uniqueId, String localTime) {
    for (var message in messages) {
      if (message.uniqueId == uniqueId) {
        // Found the message with the matching uniqueId, now update it
        message.sent = true;
        message.localTime = localTime;
        break; // Exit the loop after updating the message
      }
    }
  }
}
