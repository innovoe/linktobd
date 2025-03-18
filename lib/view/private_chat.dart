import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/main.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/chat_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/relative_timestamp.dart';

class PrivateChat extends StatefulWidget {
  final String chatPartnerName;
  final String chatPartnerImage;
  final String username;
  final String conToken;

  const PrivateChat({
    Key? key,
    required this.chatPartnerName,
    required this.chatPartnerImage,
    required this.username,
    required this.conToken
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
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.username != 'Unavailable') {
      startEngine();
    }
    print(widget.username);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    messageController.dispose(); // Dispose the message controller

    // Stop updating chatModel when the widget is disposed
    if (isChatModelInitialized) {
      chatModel.keepUpdating = false; // Ensure the chat model stops polling
    }

    // Close the chat stream to avoid memory leaks
    chatModel.chatSink.close();
    chatModel.closeChat(); // Close the stream controller

    super.dispose();
  }

  Future<void> startEngine() async {
    if(widget.conToken == ''){
      Dio dio = Dio();
      FormData formData = FormData.fromMap({'token': memory.token, 'username': widget.username});
      Response response = await dio.post(
        'https://linktobd.com/appapi/get_connection_token',
        data: formData,
      );

      var respond = response.data;
      if (respond['success'].toString() == 'yes') {
        messageToken = respond['token'].toString();
      }
    }else{
      messageToken = widget.conToken;
    }


    chatModel = ChatModel(messageToken: messageToken, bulkLoad: (List<ChatMessage> newMessages) {
      if(mounted){
        setState(() {
          messages.insertAll(0, newMessages);
        });
      };
    });

    isChatModelInitialized = true;
    // if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        currentRouteName: '/messages',
        beforeNavigate: () {
          if (isChatModelInitialized) {
            chatModel.keepUpdating = false;
          }
        },
      ),
      appBar: BadgeAppBar(
        title: widget.chatPartnerName,
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.chatPartnerImage),
            radius: 20,
          ),
        ],
      ),
      body: (messageToken == '')
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatModel.chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  ChatMessage incoming = snapshot.data as ChatMessage;
                  if (incoming.type == 'new') {
                    // setState(() {
                      messages.insert(0, incoming);
                    // });
                  } else {
                    updateMessageByUniqueId(incoming.uniqueId, incoming.localTime);
                  }
                }
                return (messages.isNotEmpty)
                    ? ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return messageWidget(message);
                  },
                )
                    : const Center(child: Text("No messages yet."));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
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
          if (!isUserMessage)
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatPartnerImage),
              radius: 15,
            ),
          Flexible(
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
                    child: Text(
                      message.message,
                      style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (message.sent)
                    RelativeTimestamp(
                      timestamp: message.localTime,
                      fontSize: 12,
                    ),
                ],
              ),
            ),
          ),
          if (isUserMessage)
            CircleAvatar(
              backgroundImage: NetworkImage(memory.photoURL),
              radius: 15,
            ),
        ],
      ),
    );
  }

  void updateMessageByUniqueId(String uniqueId, String localTime) {
    // setState(() {
      for (var message in messages) {
        if (message.uniqueId == uniqueId) {
          message.sent = true;
          message.localTime = localTime;
          break;
        }
      }
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isChatModelInitialized) {
      if (state == AppLifecycleState.resumed) {
        chatModel.keepUpdating = true;
      } else {
        chatModel.keepUpdating = false;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    checkAndUpdateModel();
  }

  @override
  void didPopNext() {
    checkAndUpdateModel();
  }

  void checkAndUpdateModel() {
    if (isChatModelInitialized && ModalRoute.of(context)?.isCurrent == true) {
      chatModel.keepUpdating = true;
    } else {
      chatModel.keepUpdating = false;
    }
  }
}
