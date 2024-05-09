import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:link2bd/model/notifiation_services.dart';
import 'package:link2bd/view/browse_people.dart';
import 'package:link2bd/view/create_post.dart';
import 'package:link2bd/view/home.dart';
import 'package:link2bd/view/login.dart';
import 'package:link2bd/view/messages.dart';
import 'package:link2bd/view/notifications.dart';
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
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Define a global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

const primaryColor = Color(0xFFB533F1);
const secondaryColor = Color(0xFFF039B6);

@pragma('vm:entry-point')
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if(message.notification != null){
    // print('notification received ${message.notification!.body}');
  }
}

Future<void> setupLocalTimezone() async {
  final String timezoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneName));
  print("Local timezone is set to: $timezoneName");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationServices notificationServices = NotificationServices();
  notificationServices.requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage((message) => _firebaseBackgroundMessage(message));
  tzdata.initializeTimeZones();
  await setupLocalTimezone();
  return runApp(MaterialApp(
    navigatorObservers: [routeObserver],
    navigatorKey: navigatorKey,
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
      '/notifications' : (context) => Notifications()
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
