import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/db_manager.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/relative_timestamp.dart';
import 'package:link2bd/model/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:link2bd/view/private_chat.dart';
import 'package:link2bd/model/custom_page_route_animator.dart';

class Messages extends StatefulWidget {
  Messages({super.key});
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late Future<List<Map<String, dynamic>>> futureMessageData;


  Future<List<Map<String, dynamic>>> fetchMessageData() async {
    // await clearTable();
    // Replace with your actual endpoint and data
    FormData formData = FormData.fromMap({'token' : memory.token});
    Dio dio = Dio();
    Response response = await dio.post(
      'https://linktobd.com/appapi/messages',
      data: formData,
    );
    List<Map<String, dynamic>> messagesList =  List<Map<String, dynamic>>.from(response.data.map((item) => {
      "name": item["name"],
      "username": item["username"],
      "message": item["small_msg"],
      "photoUrl": item["user_photo"],
      "time" : item["time"],
      "uuid" : item["uuid"]
    }));
    await saveMessagesLocal(messagesList);
    return messagesList;
  }


  Future<void> saveMessagesLocal(List<Map<String, dynamic>> messages) async {
    DbManager dbManager = DbManager();

    // Define the columns based on your database schema for the 'feeds' table
    List<String> columns = [
      'id', 'name', 'username', 'message', 'photoUrl', 'time', 'uuid'
    ];

    // Serialize the 'photos' list to a JSON string for each feed
    List<Map<String, dynamic>> serializedMessages = messages.map((message) => message).toList();
    DbTable messageTable = DbTable(tableName: 'my_message', columns: columns, rows: serializedMessages);

    await dbManager.ensureTableExists(messageTable);
    await dbManager.sync(messageTable, whereMatch: 'username');
  }

  Future<List<Map<String, dynamic>>> fetchMessageDataLocal() async {
    DbManager dbManager = DbManager();

    await dbManager.ensureTableExists(DbTable(
        tableName: 'my_message',
        columns: [
          'id', 'name', 'username', 'message', 'photoUrl', 'time', 'uuid'
        ]
    ));

    // Assuming 'messages' is your table name and it has a column named 'time' for ordering
    List<Map<String, dynamic>> rows = await dbManager.getData('my_message', 'time');

    // Transform the rows to match the structure returned by the fetchMessageData function
    // This assumes that the column names in your SQLite table match the keys used in your API response.
    // Adjust the column names if they differ.
    List<Map<String, dynamic>> transformedRows = rows.map((item) => {
      "name": item["name"],
      "username": item["username"],
      "message": item["message"], // Adjust if your local DB uses a different column name for the message
      "photoUrl": item["photoUrl"],
      "time": item["time"],
      "uuid": item["uuid"]
    }).toList();

    return transformedRows;
  }

  Future<void> clearTable()async {
    DbManager dbManager = DbManager();
    await dbManager.clearTable('my_message');
    await dbManager.dropTable('my_message');
  }


  @override
  Widget build(BuildContext context){
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/messages'),
      appBar: BadgeAppBar(title: memory.platformName),
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
            child: buildFuture(),
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> getMessages() async*{
    yield await fetchMessageDataLocal();
    try{
      yield await fetchMessageData();
      // clearTable();
    }catch(e){
      print(e);
    }
  }

  Widget buildFuture(){
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }else if (snapshot.hasData) {
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
                String postTime = message["time"].toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      CachedNetworkImageProvider('https://linktobd.com/assets/user_dp/$photoUrl'),
                    ),
                    title: Text(name, style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(messageText),
                        SizedBox(height: 3),
                        (postTime != '') ? RelativeTimestamp(timestamp: postTime, fontSize: 12) : Container(),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                          CustomPageRouteAnimator(child: PrivateChat(chatPartnerName: name, username: username, chatPartnerImage: 'https://linktobd.com/assets/user_dp/$photoUrl'), direction: 'fromRight')
                      );
                    },
                  ),
                );
              },
            ),
          );
        }else{
          return CircularProgressIndicator();
        }
      },
    );
  }


}

