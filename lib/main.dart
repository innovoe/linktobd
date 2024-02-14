import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:link2bd/model/notifiation_services.dart';
import 'package:link2bd/view/browse_people.dart';
import 'package:link2bd/view/create_post.dart';
import 'package:link2bd/view/home.dart';
import 'package:link2bd/view/login.dart';
import 'package:link2bd/view/messages.dart';
import 'package:link2bd/view/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/view/init_router.dart';
import 'package:link2bd/view/platforms.dart';
import 'package:link2bd/view/my_platforms.dart';
import 'package:link2bd/view/my_profile.dart';
import 'package:link2bd/view/platform_home.dart';
import 'package:link2bd/view/feed.dart';
import 'package:link2bd/view/create_password.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const primaryColor = Color(0xFFB533F1);
const secondaryColor = Color(0xFFF039B6);

@pragma('vm:entry-point')
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if(message.notification != null){
    print('notification received ${message.notification!.body}');
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationServices notificationServices = NotificationServices();
  notificationServices.requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage((message) => _firebaseBackgroundMessage(message));
  return runApp(MaterialApp(
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    routes: {
      '/' : (context) => InitRouter(),
      '/home' : (context) => Home(),
      '/login' : (context) => Login(),
      '/sign_up' : (context) => SignUp(),
      '/platforms' : (context) => Platforms(),
      '/my_platforms' : (context) => MyPlatforms(),
      '/platform_home' : (context) => PlatformHome(),
      '/feed' : (context) => Feed(),
      '/messages' : (context) => Messages(),
      '/my_profile' : (context) => MyProfile(),
      '/create_password' : (context) => CreatePassword(),
      '/create_post' : (context) => CreatePost(),
      '/browse_people' : (context) => BrowsePeople(keyIndex: 0),
    }
  ));
}


final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    centerTitle: false,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 16.0, // Adjust the size as needed
      fontWeight: FontWeight.w500,
    ),
  ),
  // Other theming data for light theme goes here
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    centerTitle: false,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 16.0, // Adjust the size as needed
      fontWeight: FontWeight.w500,
    ),
  ),
  // Other theming data for dark theme goes here
);
