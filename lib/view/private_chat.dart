import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/main.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/chat_model.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/relative_timestamp.dart';

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

class _PrivateChatState extends State<PrivateChat> with WidgetsBindingObserver, RouteAware {
  List<ChatMessage> messages = [];
  final TextEditingController messageController = TextEditingController();
  String messageToken = '';
  late ChatModel chatModel;
  bool isChatModelInitialized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if(widget.username != 'Unavailable'){
      startEngine();
    }
    print(widget.username);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        currentRouteName: '/messages',
        beforeNavigate: (){
          if (isChatModelInitialized) {
            chatModel.keepUpdating = false;
            WidgetsBinding.instance.removeObserver(this);
            routeObserver.unsubscribe(this);
            messageController.dispose(); // Dispose the message controller
            super.dispose();
          }
        },
      ),
      appBar: BadgeAppBar(
        title: widget.chatPartnerName,
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
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) // Chat partner's messages at start
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatPartnerImage),
              radius: 15,
            ),
          Flexible( // Make Flexible a direct child of the Row
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
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
                        //   style: TextStyle(color: Colors.grey, fontSize: 10),
                        //   textAlign: TextAlign.right,
                        // )
                      ],
                    ),
                  ),
                  SizedBox(height: 3),
                  (message.sent) ?
                  RelativeTimestamp(timestamp: message.localTime, fontSize: 12) :
                  Container(),
                ],
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
    isChatModelInitialized = true;
    await Future.delayed(Duration(milliseconds: 10));
    setState(() {
      messageToken;
      chatModel;
    });
    print(messageToken);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    messageController.dispose(); // Dispose the message controller
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (isChatModelInitialized) {
      if (state == AppLifecycleState.resumed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          checkAndUpdateModel();
        });
      } else {
        chatModel.keepUpdating = false;
      }
    }
  }

  void checkAndUpdateModel() {
    debugPrint("Checking if current: ${ModalRoute.of(context)?.isCurrent}");
    if (isChatModelInitialized) {
      if (ModalRoute
          .of(context)
          ?.isCurrent ?? false) {
        chatModel.keepUpdating = true;
      } else {
        chatModel.keepUpdating = false;
      }
    }
  }

  @override
  void didPush() {
    debugPrint("didPush - Route was pushed");
    checkAndUpdateModel();
  }

  @override
  void didPopNext() {
    debugPrint("didPopNext - Came back to this route");
    checkAndUpdateModel();
  }

  @override
  void didPop() {
    debugPrint("didPop - Route was popped");
    if (isChatModelInitialized) {
      chatModel.keepUpdating = false;
    }
  }

  @override
  void didPushNext() {
    debugPrint("didPushNext - New route pushed");
    if (isChatModelInitialized) {
      chatModel.keepUpdating = false;
    }
  }
}
