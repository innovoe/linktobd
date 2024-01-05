import 'package:link2bd/view/home.dart';
import 'package:link2bd/view/login.dart';
import 'package:link2bd/view/profile_view.dart';
import 'package:link2bd/view/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/view/init_router.dart';
import 'package:link2bd/view/platforms.dart';
import 'package:link2bd/view/my_platforms.dart';
import 'package:link2bd/view/platform_home.dart';
import 'package:link2bd/view/feed.dart';

const primaryColor = Color(0xFFB533F1);
const secondaryColor = Color(0xFFF039B6);


void main(){
  WidgetsFlutterBinding.ensureInitialized();
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
      '/profile_view' : (context) => ProfileView(),
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
