import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:link2bd/model/login_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/notifiation_services.dart';
import 'package:link2bd/model/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/token_manager.dart';


class InitRouter extends StatefulWidget {
  const InitRouter({Key? key}) : super(key: key);

  @override
  _InitRouterState createState() => _InitRouterState();
}


class _InitRouterState extends State<InitRouter> {

  String message = '';
  bool locked = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationServices notificationServices = NotificationServices();
    notificationServices.requestNotificationPermission();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _navigateTo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                child: message == '' ? CircularProgressIndicator() : Text(message),
              ),
              SizedBox(height: 20),
              locked ? OutlinedButton(
                  child: Icon(Icons.refresh),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/');
                  }
              ) :
              ElevatedButton(
                child: Text('Let\'s Go!'),
                onPressed: () async{
                  message = '';
                  setState(() {});
                  // Navigator.pushReplacementNamed(context, '/my_platforms');
                  LoginModel loginModel = LoginModel();
                  int id = await loginModel.getId();

                  if(id == 0){
                    Navigator.pushReplacementNamed(context, '/login');
                  }else{
                    if(await checkConnectivity()){
                      await firebasePushTokenManagement();
                    }
                    Navigator.pushReplacementNamed(context, '/my_platforms');
                  }
                }
              )
            ],
          )
      ),
    );
  }

  void _navigateTo() async{
    if(await checkConnectivity()){
      try{
        UserModel userModel = UserModel();
        await userModel.getUserName();
        try {
          Dio dio = Dio();
          final formData = FormData.fromMap({
            'token': memory.token
          });
          Response response = await dio.post(
              'https://linktobd.com/appapi/check_con',
              data: formData
          );
          var respond =  response.data;
          message = respond['success'].toString();
          locked = false;
          setState(() {});
        } catch (e) {
          message = 'Internet Connection Down. $e.';
          // message = 'You are offline.';
          locked = false;
          setState(() {
          });
        }
      }catch(e){
        message = 'Failed to connect to the internet. Internet connection is must for signing up or logging in.';
        locked = false;
        setState(() {
        });
      }

    }else{
      setState(() {
        locked = false;
        message = 'Found No Internet Connection.';
      });
    }

  }

  Future<void> firebasePushTokenManagement() async{
    FirebaseMessaging firebaseMessaging;
    firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.subscribeToTopic('social');
    String? token = await FirebaseMessaging.instance.getToken();
    TokenManager tokenManager = TokenManager();
    if (token != null) {
      await tokenManager.addToken(token); // Add the token to SQLite
    }

    // Handle token refresh
    firebaseMessaging.onTokenRefresh.listen((String newToken) async {
      await tokenManager.addToken(newToken); // Update with the new token
      token = newToken;
    });
    if(token != null){
      print(token);
      FormData formData = FormData.fromMap({'token' : memory.token, 'push_firebase_token' : token.toString()});
      Dio dio = Dio();
      var responses = await dio.post(
        'https://linktobd.com/appapi/push_firebase_token',
        data: formData,
      );
    }
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;  // No network connection
    } else {
      return await isInternetAvailable();  // Check internet availability
    }
  }

  Future<bool> isInternetAvailable() async {
    Dio dio = Dio();
    try {
      final response = await dio.get('https://linktobd.com/appapi/check_con').timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        // Consider checking response content if necessary
        return true;  // Internet is available
      } else {
        return false;  // Server responded, but not success
      }
    } catch (e) {
      return false;  // An error occurred, likely no internet
    }
  }
}

