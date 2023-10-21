import 'package:link2bd/view/home.dart';
import 'package:link2bd/view/login.dart';
import 'package:link2bd/view/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/view/init_router.dart';
import 'package:link2bd/view/platforms.dart';
import 'package:link2bd/view/platform_home.dart';

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
      '/platform_home' : (context) => PlatformHome(),
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
  // Other theming data for dark theme goes here
);