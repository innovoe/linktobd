import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String currentRouteName;

  AppDrawer({required this.currentRouteName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'User',
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.bodyLarge?.color,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.person, 'My Profile', '/my_profile'),
          _buildDrawerItem(context, Icons.explore, 'Platforms', '/platforms'),
          _buildDrawerItem(context, Icons.star, 'My Platforms', '/my_platforms'),
          _buildDrawerItem(context, Icons.message, 'Messages', '/messages'),
          _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),
          // Add more drawer items here...
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String routeName) {
    bool isSelected = currentRouteName == routeName;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : null),
      ),
      selected: isSelected,
      onTap: () {
        if (currentRouteName != routeName) {
          Navigator.of(context).pushReplacementNamed(routeName);
        } else {
          Navigator.of(context).pop();  // Close the drawer if the current route is selected
        }
      },
    );
  }
}
