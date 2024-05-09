import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/user_model.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();
    return Scaffold(
      appBar: BadgeAppBar(title: 'My Profile',),
      drawer: AppDrawer(currentRouteName: '/my_profile'),
      body: userModel.userProfileData(context)
    );
  }
}
