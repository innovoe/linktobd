import 'dart:core';

import 'package:flutter/material.dart';
import 'package:linktobd/model/feed_model.dart';
import 'package:linktobd/model/widgets.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/feed_card.dart';
import 'package:linktobd/model/app_drawer.dart';

class SinglePost extends StatefulWidget {
  final String uuid;
  final VoidCallback runThis;
  SinglePost({Key? key, required this.uuid,VoidCallback? runThis}) :
  runThis = runThis ?? (() {}), super(key: key);

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  int? selectedPlatform;
  int platformIdSelected = 1;
  UniqueKey _uniqueKey = UniqueKey();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    widget.runThis();
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/feed'),
      appBar: AppBar(
        title: Text('post: ${memory.platformName}'),
        // actions: [
        //   TextButton(
        //     child: Text('New Post +'),
        //     onPressed: (){
        //       Navigator.pushNamed(context, '/create_post');
        //     },
        //   )
        // ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              topMenuItem(context, 'Feed', '/feed', true),
              topMenuItem(context, 'People', '/browse_people'),
              topMenuItem(context, 'Messages', '/messages')
            ],
          ),
          Container(color: primaryColor, height: 1,),
          StreamBuilder(
            stream: getPost(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.hasData) {
                Map<String, dynamic> response = snapshot.data!;
                double screenHeight = MediaQuery.of(context).size.height;
                return SizedBox(
                  height: screenHeight - 150,
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return FeedCard(feedData: response, setFeedState: setFeedState);
                    },
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Stream<Map<String, dynamic>> getPost() async*{
    FeedModel feedModel = FeedModel();
    // List<Map<String, dynamic>> offlineFeed = await feedModel.getFeedLocal();
    // yield offlineFeed;
    try{
      Map<String, dynamic> onlineSinglePost = await feedModel.getSinglePost(widget.uuid);
      yield onlineSinglePost;
    }catch(e){
      print(e);
      // yield offlineFeed;
    }
  }


  void setFeedState() {
    double currentPosition = _scrollController.offset;
    _uniqueKey = UniqueKey();
    setState(() {});
    Future.delayed(Duration(seconds: 1), (){
      _scrollController.jumpTo(currentPosition);
    });
  }

}
