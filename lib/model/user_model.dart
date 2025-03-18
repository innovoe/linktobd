import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/data_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:linktobd/model/memory.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class UserModel{
  final primaryColor = Color(0xFFB533F1);
  final secondaryColor = Color(0xFF24CF81);
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

        String name = (respond['nickname'] == null || respond['nickname'] == '') ? 'User' : respond['nickname'];
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

  Future<bool> passwordCheck() async{
    try {
      FormData formData = FormData.fromMap({'token' : memory.token});
      Dio dio = Dio();
      Response respond = await dio.post(
          'https://linktobd.com/appapi/get_user_platforms',
          data: formData
      );
      var response = respond.data;
      if(response['success'].toString() == 'yes'){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<Map<String, String>> profileCompletionCheck() async{
    try {
      FormData formData = FormData.fromMap({'token' : memory.token});
      Dio dio = Dio();
      Response respond = await dio.post(
          'https://linktobd.com/appapi/profile_check',
          data: formData
      );
      var response = respond.data;
      Map<String, String> completion = {
        'success' : response['success'].toString(),
        'completion' : response['completion'].toString(),
      };
      return completion;
    } catch (e) {
      print(e.toString());
      return {};
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
                    if(memory.platformId == 0){
                      memory.platformId = int.parse(platform['id']);
                      memory.platformName = platform['title'] as String;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            memory.platformId = int.parse(platform['id']);
                            memory.platformName = platform['title'] as String;
                            Navigator.pushNamed(context, '/feed');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                colors: Theme.of(context).brightness == Brightness.dark
                                    ? [
                                  Colors.black45,Colors.black38
                                ]
                                    : [

                                  // primaryColor.withOpacity(0.4),
                                  Colors.white,Colors.white,Colors.white,Colors.white,
                                  // secondaryColor.withOpacity(0.4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              // Adding the drop shadow
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.1), // Soft shadow
                                  spreadRadius: 2, // Spread of the shadow
                                  blurRadius: 10, // Softness of the shadow
                                  offset: Offset(1, 8), // Position of the shadow (right & down)
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                getIconFromPlatformId(platform['id'], 50), // Slightly larger icon
                                SizedBox(height: 5), // Space between icon and text
                                Text(
                                  platform['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    letterSpacing: 1.2, // For more refined typography
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center, // Center the text
                                ),
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
        return Icon(Icons.group, size: iconSize, color: Colors.purple);
      case '2':
        return Icon(Icons.business, size: iconSize, color: Colors.purple);
      case '3':
        return Icon(Icons.favorite, size: iconSize, color: Colors.purple);
      case '4':
        return Icon(Icons.travel_explore, size: iconSize, color: Colors.purple);
      case '5':
        return Icon(Icons.school, size: iconSize, color: Colors.purple);
      default:
        return Icon(Icons.accessibility_rounded, size: iconSize, color: Colors.purple);
    }
  }

  Future<dynamic> userProfileInfo() async{
    final formData = FormData.fromMap({
      'token': memory.token
    });
    // Dio dio = Dio();
    // var respond = await dio.post('https://linktobd.com/appapi/user_profile', data: formData);
    //
    // return respond;
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
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.grey),
          onPressed: () {
            // Handle edit action
          },
        ),
      ),
    );
  }

  Widget userProfileDataOld(BuildContext context){
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
  }

  Widget userProfileData(BuildContext context) {
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
                      SizedBox(height: 20,),
                      CircleAvatar(
                        radius: 75,  // Increased size
                        backgroundImage: NetworkImage('https://linktobd.com/assets/user_dp/${uData['photo'] ?? ''}'),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(height: 8),
                      Text(uData['name'] ?? '', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                      detailCard('Email', uData['email'] ?? 'Not available', Icons.email),
                      detailCard('Phone', uData['phone'] ?? 'Not available', Icons.phone),
                      detailCard('Date of Birth', uData['dateofbirth'] ?? 'Not available', Icons.cake),
                      detailCard('Occupation', uData['occupation'] ?? 'Not available', Icons.work),
                      detailCard('Joined', uData['created'] ?? 'Not available', Icons.calendar_today),
                      detailCard('Nickname', uData['nickname'] ?? 'Not available', Icons.person),
                      detailCard('Height', uData['height_id'] ?? 'Not available', Icons.accessibility),
                      detailCard('Username', uData['username'] ?? 'Not available', Icons.account_circle),
                      detailCard('Password', uData['password'] ?? 'Not available', Icons.lock),
                      detailCard('Gender', uData['gender_id'] ?? 'Not available', Icons.wc),
                      detailCard('Education', uData['education'] ?? 'Not available', Icons.school),
                      detailCard('Religion', uData['religion'] ?? 'Not available', Icons.account_balance),
                      detailCard('City', uData['city'] ?? 'Not available', Icons.location_city),
                      detailCard('State', uData['state'] ?? 'Not available', Icons.map),
                      detailCard('Zip Code', uData['zip_code'] ?? 'Not available', Icons.code),
                      // detailCard('Country', uData['country_id'] ?? 'Not available', Icons.flag),
                      // detailCard('Status', uData['status'] ?? 'Not available', Icons.info),
                      // More details can be added here
                    ],
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          );
        }
      },
    );
  }

  // Widget detailCard(String title, String value, IconData icon) {
  //   return Card(
  //     child: ListTile(
  //       leading: Icon(icon, color: Colors.purple),
  //       title: Text(title),
  //       subtitle: Text(value ?? 'Not available'),
  //     ),
  //   );
  // }




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