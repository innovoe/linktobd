import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async{
    NotificationSettings notificationSettings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    if(notificationSettings.authorizationStatus == AuthorizationStatus.authorized){
      print('user granted authorized permission');
    }else if(notificationSettings.authorizationStatus == AuthorizationStatus.provisional){
      print('user granted provisional permission');
    }else{
      print('user denied permission');
    }
    String token = await getNotificationToken();
    print(token);
  }

  Future<String> getNotificationToken() async{
    String? getToken = await firebaseMessaging.getToken();
    return getToken ?? '';
  }
}