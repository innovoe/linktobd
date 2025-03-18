import 'package:flutter/material.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/badge_appbar.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';

class MyPlatforms extends StatefulWidget {
  const MyPlatforms({Key? key}) : super(key: key);

  @override
  State<MyPlatforms> createState() => _MyPlatformsState();
}

class _MyPlatformsState extends State<MyPlatforms> {
  static const secondaryColor = Color(0xFFF039B6);

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
        drawer: AppDrawer(currentRouteName: '/my_platforms'),
        appBar: BadgeAppBar(title: 'My Platforms',),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: userModel.userPlatformWidget(context),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help_desk');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.handshake_outlined, size: 30,),
                SizedBox(height: 5,),
                Text('Help Center')
              ],
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(80),
              backgroundColor: Colors.green[400], // Set the background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded button corners
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leaving already?'),
        content: Text('Do you really want to close the app and miss out on what’s happening?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay on the app
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit the app
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false; // Return false if the user dismisses the dialog (e.g., by tapping outside).
  }
}
