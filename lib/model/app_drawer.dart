import 'package:flutter/material.dart';
import 'package:linktobd/model/login_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart';
import 'package:linktobd/view/login.dart';

class AppDrawer extends StatelessWidget {
  final String currentRouteName;
  final VoidCallback beforeNavigate;

  static void noFunction() {}

  AppDrawer({required this.currentRouteName, this.beforeNavigate = noFunction});

  @override
  Widget build(BuildContext context) {
    UserModel userModel = UserModel();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              children: [
                userModel.userPhoto(context),
                SizedBox(height: 10,),
                userModel.userName(context)
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.notifications, 'Notifications', '/notifications', badgeCount: memory.newNotifications),
          _buildDrawerItem(context, Icons.person, 'My Profile', '/my_profile'),
          _buildDrawerItem(context, Icons.explore, 'Platforms', '/platforms'),
          _buildDrawerItem(context, Icons.star, 'My Platforms', '/my_platforms'),
          _buildDrawerItem(context, Icons.message, 'Messages', '/messages'),
          _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),
          _logoutWidget(context)
          // Add more drawer items here...
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String routeName, {int badgeCount = 0}) {
    bool isSelected = currentRouteName == routeName;

    return ListTile(
      leading: Stack(
        children: <Widget>[
          Icon(icon, color: isSelected ? Colors.green : null), // Icon with conditional color
          if (badgeCount > 0) // Conditionally display the badge
            Positioned( // Badge in the top-right corner of the icon
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.green : null),
      ),
      selected: isSelected,
      onTap: () {
        beforeNavigate();
        if (currentRouteName != routeName) {
          Navigator.of(context).pushReplacementNamed(routeName);
        } else {
          Navigator.of(context).pop();  // Close the drawer if the current route is selected
        }
      },
    );
  }


  Widget _logoutWidget(BuildContext context){
    return ListTile(
      leading: Icon(Icons.logout),
      title: Text(
        'Logout'
      ),
      selected: false,
      onTap: () async{
        LoginModel loginModel = LoginModel();
        if(await loginModel.logout()) {
          // This ensures that all routes are removed and only the login route is pushed
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()), // Assume LoginPage is your login page widget
                (Route<dynamic> route) => false, // Removes all routes below the pushed route
          );
        }
        // if(await loginModel.logout()){
        //   // ignore: use_build_context_synchronously
        //   Navigator.of(context).popUntil((route) => route.isFirst);
        // }
      },
    );
  }
}
