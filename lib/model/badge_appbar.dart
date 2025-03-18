import 'dart:async';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/user_model.dart'; // Alias added

class BadgeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  BadgeAppBar({required this.title, this.actions});

  @override
  State<BadgeAppBar> createState() => _BadgeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

}

class _BadgeAppBarState extends State<BadgeAppBar> {
  Timer? timer;
  int cacheUpdatedNotificationNr = 0;

  @override
  void initState() {
    super.initState();
    checkNotificationNumberOfRows();
  }

  @override
  Widget build(BuildContext context) {
    int badgeCount = memory.newNotifications;
    return AppBar(
      title: Text(widget.title),
      actions: widget.actions,
      leading: Builder(
        builder: (BuildContext context) {
          return badges.Badge(
            showBadge: badgeCount > 0,
            badgeContent: Text(
              badgeCount.toString(),
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            position: badges.BadgePosition.topEnd(top: 5, end: 5),
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> checkNotificationNumberOfRows() async {
    UserModel userModel = UserModel();
    await userModel.getNotificationsNumberOfRowsLocalFile();
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      int updatedNumberOfRows = await userModel.notificationNumberOfRows();
      // print(updatedNumberOfRows);
      // print(memory.notificationNr);
      // print(cacheUpdatedNotificationNr);
      if (updatedNumberOfRows != cacheUpdatedNotificationNr) {
        int newNotifications = updatedNumberOfRows - memory.notificationNr;
        cacheUpdatedNotificationNr = updatedNumberOfRows;
        memory.newNotifications = newNotifications;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
