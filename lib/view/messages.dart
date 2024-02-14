import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:link2bd/view/private_chat.dart';

import '../model/custom_page_route_animator.dart';

class Messages extends StatefulWidget {
  Messages({super.key});
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late Future<List<Map<String, dynamic>>> futureMessageData;

  @override
  void initState() {
    super.initState();
    futureMessageData = fetchMessageData();
  }

  Future<List<Map<String, dynamic>>> fetchMessageData() async {
    // Replace with your actual endpoint and data
    FormData formData = FormData.fromMap({'token' : memory.token});
    Dio dio = Dio();
    Response response = await dio.post(
      'https://linktobd.com/appapi/messages',
      data: formData,
    );

    if (response.statusCode == 200) {
      // Assuming the response data is a list of maps
      return List<Map<String, dynamic>>.from(response.data.map((item) => {
        "name": item["name"],
        "username": item["username"],
        "message": item["small_msg"],
        "photoUrl": item["user_photo"],
      }));
    } else {
      throw Exception('Failed to load messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/messages'),
      appBar: AppBar(
        title: Text(memory.platformName),
      ),
      body: Column(
        children: [
          Row(
            children: [
              topMenuItem(context, 'Feed', '/feed'),
              topMenuItem(context, 'People', '/browse_people'),
              topMenuItem(context, 'Messages', '/messages', true),
            ],
          ),
          Container(color: primaryColor, height: 1,),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureMessageData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var message = snapshot.data![index];
                        String name = message["name"] ?? '';
                        String messageText = message["message"] ?? '';
                        String username = message["username"] ?? '';
                        String photoUrl = message["photoUrl"] ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                            CachedNetworkImageProvider('https://linktobd.com/assets/user_dp/$photoUrl'),
                          ),
                          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                          subtitle: Text(messageText),
                          onTap: () {
                            Navigator.of(context).push(
                                CustomPageRouteAnimator(child: PrivateChat(chatPartnerName: name, username: username, chatPartnerImage: 'https://linktobd.com/assets/user_dp/$photoUrl'), direction: 'fromRight')
                            );
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text("No messages found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
