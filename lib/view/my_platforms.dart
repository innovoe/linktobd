import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/user_model.dart';


class MyPlatforms extends StatefulWidget {
  const MyPlatforms({Key? key}) : super(key: key);

  @override
  State<MyPlatforms> createState() => _MyPlatformsState();
}

class _MyPlatformsState extends State<MyPlatforms> {

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/my_platforms'),
      appBar: BadgeAppBar(title: 'My Platforms',),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userModel.userPlatformWidget(context),
      ),
    );
  }
}
