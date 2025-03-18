import 'package:flutter/material.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';

class Platforms extends StatefulWidget {
  const Platforms({Key? key}) : super(key: key);

  @override
  State<Platforms> createState() => _PlatformsState();
}

class _PlatformsState extends State<Platforms> {

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    UserModel userModel = UserModel();

    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/platforms',),
      appBar: BadgeAppBar(title: 'Choose a Platform',),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("As a new user, you are granted access to one group for free initially. To join additional groups, a fee will be required. Please choose your first group with care and make sure it aligns with your primary interest!"),
            SizedBox(height: 20),
            userModel.listPlatformWidget(context)
          ],
        ),
      ),
    );
  }
}
