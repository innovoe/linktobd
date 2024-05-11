import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/data_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:link2bd/model/memory.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class UserModel{

  final String key1 = 'dontyoucryurikufiaddontyoucryurikufiad';
  final String key2 = 'letsgoyeahcomeoncomeonturntheradioonitsfrydaynight';
  final String clientUrl = 'https://linktobd.com/appapi/app_login';


  Future<String> getUserName() async{
    if(memory.username == ''){
      try {
        FormData formData = FormData.fromMap({'token' : memory.token});
        DataModel dataModel = DataModel();
        var respond = await dataModel.getJSONData(
            'https://linktobd.com/appapi/user_profile',
            formData,
            'user_profile_data'
        );

        String name = respond['nickname'];
        String photo = respond['photo'];
        memory.username = name;
        memory.photoURL = 'https://linktobd.com/assets/user_dp/$photo';
        return memory.username;
      } catch (e) {
        // Handle the error
        return (e.toString());
      }
    }else{
      return memory.username;
    }
  }

  Widget userName(context){
    if(memory.username == ''){
      return FutureBuilder(
        future: getUserName(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }else if(snapshot.hasData){
            return Text(snapshot.data.toString());
          }else{
            return Text('...');
          }
        },
      );
    }else{
      return Text(memory.username);
    }
  }

  Widget userPhoto(context){
    if(memory.photoURL == ''){
      return FutureBuilder(
        future: getUserName(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }else if(snapshot.hasData){
            return CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(memory.photoURL),
              radius: 50,
            );
          }else{
            return Text('...');
          }
        },
      );
    }else{
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(memory.photoURL),
        radius: 50,
      );
    }
  }

  Future<dynamic> getUserPlatforms() async{
    Dio dio = Dio();
    final formData = FormData.fromMap({
      'token': memory.token
    });
    DataModel dataModel = DataModel();
    var response = await dataModel.getJSONData('https://linktobd.com/appapi/get_user_platforms', formData, 'user_platform_data');
    // Response response = await dio.post(
    //     'https://linktobd.com/appapi/get_user_platforms',
    //     data: formData
    // );
    return response;
  }

  Widget userPlatformWidget(BuildContext context){
    return FutureBuilder(
      future: getUserPlatforms(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else if(snapshot.hasData){
          var platforms = snapshot.data;
          Color primaryColor = Theme.of(context).primaryColor;
          if(platforms.isEmpty){
            return Column(
              children: [
                Text("Welcome to our community! As a newcomer, we're excited to offer you complimentary access to one of our exclusive platforms. This is a special opportunity for you to explore and engage with a community that resonates with your passions and interests.\n\nPlease take a moment to consider your options carefully. Each platform is unique, catering to a variety of interests and hobbies. Remember, this is your chance to connect with like-minded individuals and immerse yourself in a subject you love.\n\nKeep in mind that this is your initial free platform choice. In the future, if you wish to broaden your horizons and join additional groups, there will be a nominal fee involved. This policy helps us maintain the quality and exclusivity of our platforms.\n\nSo, dive in, explore, and choose the platform that best aligns with your primary interest. We're here to make sure your experience is enriching and enjoyable. Welcome aboard!\n\n"),
                ElevatedButton(
                  child: Text('Choose a platform'),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/platforms');
                  },
                )
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: platforms.length,
                  itemBuilder: (context, index) {
                    final platform = platforms[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: (index % 2 == 0) ? primaryColor : Colors.green[400],
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            memory.platformId = int.parse(platform['id']);
                            memory.platformName = platform['title'] as String;
                            Navigator.pushReplacementNamed(context, '/feed');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              children: [
                                getIconFromPlatformId(platform['id'], 50),
                                Text(platform['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  Future<dynamic> getAllPlatforms() async{
    final formData = FormData.fromMap({
      'token': memory.token
    });
    DataModel dataModel = DataModel();
    var response = await dataModel.getJSONData(
      'https://linktobd.com/appapi/get_all_platforms',
      formData,
      'all_platforms_data'
    );
    return response;
  }

  Widget listPlatformWidget(BuildContext context){
    return FutureBuilder(
      future: getAllPlatforms(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else if(snapshot.hasData){
          var platforms = snapshot.data;
          Color primaryColor = Theme.of(context).primaryColor;
          return Expanded(
            child: ListView.builder(
              itemCount: platforms.length,
              itemBuilder: (context, index) {
                final platform = platforms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        memory.platformId = platform['id'] as int;
                        Navigator.pushNamed(context, '/platform_home');
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0), // The desired top-left corner radius
                              topRight: Radius.circular(8.0), // The desired top-right corner radius
                            ),
                            child: Image.asset(platform['image'] as String, width: double.infinity, height: 120, fit: BoxFit.cover),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Row(
                              children: [
                                getIconFromPlatformId(platform['id'], 20),
                                SizedBox(width: 5),
                                Expanded(child: Text(platform['title'] as String, style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Opacity(
                                  opacity: 0.0,
                                  child: getIconFromPlatformId(platform['id'], 20),
                                ),
                                SizedBox(width: 5),
                                Expanded(child:Text(platform['subtitle'] as String),),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                memory.platformId = int.parse(platform['id']);
                                Navigator.pushNamed(context, '/platform_home');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                              child: Text('Join'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget getIconFromPlatformId(String platformId, double iconSize){
    switch(platformId){
      case '1':
        return Icon(Icons.group, size: iconSize);
      case '2':
        return Icon(Icons.business, size: iconSize);
      case '3':
        return Icon(Icons.favorite, size: iconSize);
      case '4':
        return Icon(Icons.travel_explore, size: iconSize);
      case '5':
        return Icon(Icons.school, size: iconSize);
      default:
        return Icon(Icons.accessibility_rounded, size: iconSize);
    }
  }

  Future<dynamic> userProfileInfo() async{
    final formData = FormData.fromMap({
      'token': memory.token
    });
    DataModel dataModel = DataModel();
    var respond = await dataModel.getJSONData(
        'https://linktobd.com/appapi/user_profile',
        formData,
        'user_profile_data'
    );
    return respond;
  }

  Widget detailCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title),
        subtitle: Text(value ?? 'Not available'),
      ),
    );
  }

  Widget userProfileData(BuildContext context){
    return FutureBuilder(
      future: userProfileInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var uData = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      CircleAvatar(
                        radius: 70,  // Increased size
                        backgroundImage: NetworkImage('https://linktobd.com/assets/user_dp/${uData['photo']}'),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(height: 8),
                      Text(uData['name'], style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(uData['short_bio'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
                AnimatedSwitcher(  // Adding an animation for switching between details
                  duration: Duration(milliseconds: 500),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      detailCard('Email', uData['email'], Icons.email),
                      detailCard('Phone', uData['phone'], Icons.phone),
                      detailCard('Date of Birth', uData['dateofbirth'], Icons.cake),
                      detailCard('Occupation', uData['occupation'], Icons.work),
                      detailCard('Joined', uData['created'], Icons.calendar_today),
                      // More details can be added here
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
    return FutureBuilder(
      future: userProfileInfo(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else if(snapshot.hasData){
          var uData = snapshot.data;
          String uPhotoURL = 'https://linktobd.com/assets/user_dp/${uData['photo']}';
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height - 70,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(uData['name']), // This text will be overlaid at the bottom
                  background: Image.network(
                    uPhotoURL,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: EdgeInsets.only(left: 75, top: 8),
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('15 Connections', style: TextStyle(fontSize: 20),),
                          SizedBox(height: 55,),
                          if(uData['nickname'] != null) Text('Nickname\n${uData['nickname']}\n'),
                          if(uData['email'] != null) Text('Email\n${uData['email']}\n'),
                          if(uData['dateofbirth'] != null) Text('Date Of Birth\n${uData['dateofbirth']}\n'),
                          if(uData['phone'] != null) Text('Phone\n${uData['phone']}\n'),
                          if(uData['short_bio'] != null) Text('Short Bio\n${uData['short_bio']}\n'),
                          if(uData['occupation'] != null) Text('Occupation\n${uData['occupation']}\n'),
                          if(uData['created'] != null) Text('Joined\n${uData['created']}\n'),
                        ],
                      )
                    ),
                  ],
                ),
              ),
            ],
          );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }



  //0 means new file created
  Future<int> getId() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath = '${appDir.path}/id.txt';
    File idFile = File(idFilePath);
    if(await idFile.exists()){
      String data = await idFile.readAsString();
      memory.token = int.parse(data);
      return int.parse(data);
    }else{ //file doesn't exist
      idFile.create(recursive: true);
      idFile.writeAsString('0');
      memory.token = 0;
      return 0;
    }
  }

  Future<String> appLogin(String username, String password) async {
    var client = http.Client();
    try{
      var webResponse = await client.post(
          Uri.parse(clientUrl),
          body: {
            'key1' : key1,
            'key2' : key2,
            'username' : username,
            'password' : password
          }
      );
      if(webResponse.body == 'auth_error'){
        return 'Authentication Error. Please contact System Administrator.';
      }else if(webResponse.body == '0'){
        return 'Wrong username or password';
      }else{
        memory.token = int.parse(webResponse.body);
        saveId();
        return 'Login Success';
      }
    }catch(e){
      return 'Server Error ${e.toString()}  Please contact System Administrator';
    }
  }

  Future<void> saveId() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath =  '${appDir.path}/id.txt';
    File idFile = File(idFilePath);
    idFile.writeAsString(memory.token.toString());
  }

  Future<int> notificationNumberOfRows() async{
    FormData formData = FormData.fromMap({'token' : memory.token});
    Dio dio = Dio();
    var responses = await dio.post(
      'https://linktobd.com/appapi/get_notification_nr',
      data: formData,
    );
    var response = responses.data;
    int numberOfRows = int.parse(response['nr'].toString());
    return numberOfRows;
  }

  Future<int> getNotificationsNumberOfRowsLocalFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath = '${appDir.path}/notification_nr.txt';
    File idFile = File(idFilePath);
    if(await idFile.exists()){
      String data = await idFile.readAsString();
      memory.notificationNr = int.parse(data);
      return int.parse(data);
    }else{ //file doesn't exist
      idFile.create(recursive: true);
      idFile.writeAsString('0');
      memory.notificationNr = 0;
      return 0;
    }
  }

  Future<void> saveNotificationsNumberOfRowsLocalFile() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String idFilePath =  '${appDir.path}/notification_nr.txt';
    File idFile = File(idFilePath);
    await idFile.writeAsString(memory.notificationNr.toString());
  }

  Future<List<Map<String, dynamic>>> notificationsOnline() async{
    FormData formData = FormData.fromMap({'token' : memory.token});
    Dio dio = Dio();
    var responses = await dio.post(
      'https://linktobd.com/appapi/get_notifications',
      data: formData,
    );

    List<Map<String, dynamic>> notifications = [];
    for (var response in responses.data) {
      var notification = {
        'username': response['username'].toString(), // adjusted key to match
        'user_photo': response['user_photo'].toString(),
        'text': response['text'].toString(),
        'time': response['time'].toString(),
        'tablename': response['tablename'].toString(),
        'user_id': response['user_id'].toString(),
        'module': response['module'].toString(),
        'post_id': response['post_id'].toString(),
        'post_uuid': response['post_uuid'].toString(),
        'platform_id': response['platform_id'].toString(),
        'platform_name': response['platform_name'].toString(),
        'comment_id': response['comment_id'].toString(),
        'reply_id': response['reply_id'].toString(),
      };
      notifications.add(notification);
    }
    // List<Map<String, dynamic>> feedLocal = feeds;
    // await saveFeedLocal(feedLocal);
    return notifications;
  }

}