import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/relative_timestamp.dart';
import 'package:link2bd/model/user_model.dart';
import 'package:link2bd/view/comment_reply.dart';
import 'package:link2bd/view/post_comment.dart';
import 'package:link2bd/view/single_post.dart';

import '../model/custom_page_route_animator.dart';


class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Timer? timer;
  StreamController<List<Map<String, dynamic>>> _controller = StreamController();

  @override
  void initState() {
    super.initState();
    startNotificationStream();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/notifications'),
      appBar: AppBar(title: Text('Notifications'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: getNotification(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Display error message if the stream emits an error
              return Text('Error: ${snapshot.error.toString()}');
            } else if (snapshot.hasData) {
              // Check if there are notifications
              if (snapshot.data!.isEmpty) {
                // Display a message if there are no notifications
                return Text('No notifications.');
              } else {
                print(snapshot.data.toString());
                // Build a list view of notifications if there are any
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var notification = snapshot.data![index];
                    return ListTile(
                      leading: notification['user_photo'] != null
                          ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider('${notification['user_photo']}'),
                      )
                          : CircleAvatar(
                        child: Icon(Icons.person), // Default icon if no photo is provided
                      ),
                      title: Text(notification['text'] ?? 'Notification'), // Default text if null
                      subtitle: (notification['time'] != null) ? RelativeTimestamp(timestamp: notification['time']) : Text(''), // Show time if provided
                      onTap: () async{
                        String module = notification['module'] ?? '';
                        String reply_id = notification['reply_id'] ?? '';
                        String comment_id = notification['comment_id'] ?? '';
                        String post_uuid = notification['post_uuid'] ?? '';
                        String post_id = notification['post_id'] ?? '';
                        int platformId = int.parse(notification['platform_id']) ?? 0;
                        String platformName = notification['platform_name'] ?? '';

                        memory.platformId = platformId;
                        memory.platformName = platformName;

                        memory.postId = post_id;
                        memory.postUuid = post_uuid;
                        memory.commentId = comment_id;

                        if(module == 'post' || module == 'post_like'){
                          await Navigator.of(context).push(
                              CustomPageRouteAnimator(
                                  child: SinglePost(uuid: post_uuid),
                                  direction: 'fromRight'
                              )
                          );
                        }else if(module == 'comment' || module == 'comment_like'){
                          await Navigator.of(context).push(
                              CustomPageRouteAnimator(
                                  child: CommentReply(),
                                  direction: 'fromRight'
                              )
                          );
                        }else if(module == 'message'){
                          await Navigator.pushNamed(context, '/messages');
                        }
                      },
                    );
                  },
                );
              }
            } else {
              // Display a loading spinner while waiting for the data
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }


  void startNotificationStream() async {
    UserModel userModel = UserModel();
    await userModel.getNotificationsNumberOfRowsLocalFile();
    memory.newNotifications = 0;
    int updatedNumberOfRows = await userModel.notificationNumberOfRows();
    memory.notificationNr = updatedNumberOfRows;
    await userModel.saveNotificationsNumberOfRowsLocalFile();
    _controller.add(await userModel.notificationsOnline());  // Initial load

    timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      int updatedNumberOfRows = await userModel.notificationNumberOfRows();
      // print(updatedNumberOfRows);
      // print(memory.notificationNr);
      if (updatedNumberOfRows > memory.notificationNr) {
        memory.notificationNr = updatedNumberOfRows;
        await userModel.saveNotificationsNumberOfRowsLocalFile();
        _controller.add(await userModel.notificationsOnline());  // Update stream with new data
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getNotification() {
    return _controller.stream;
  }


  Future<void> notificationRedirect(var notification) async{
    print(notification);
  }

  Future<void> goToComment() async{
    await Navigator.of(context).push(
        CustomPageRouteAnimator(
          child: PostComment(setFeedState: (){}),
          direction: 'fromRight',
          runThis: goToReply
        )
    );
  }

  Future<void> goToReply() async{
    await Navigator.of(context).push(
        CustomPageRouteAnimator(child: CommentReply(setCommentState: (){}, setFeedState: (){}), direction: 'fromRight')
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
    _controller.close();
  }

}
