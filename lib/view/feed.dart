import 'package:flutter/material.dart';
import 'package:link2bd/model/badge_appbar.dart';
import 'package:link2bd/model/feed_model.dart';
import 'package:link2bd/model/widgets.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/feed_card.dart';
import 'package:link2bd/model/app_drawer.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int? selectedPlatform;
  int platformIdSelected = 1;
  List<Map<String, dynamic>> feeds = [];
  UniqueKey _uniqueKey = UniqueKey();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    FeedModel feedModel = FeedModel();
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/feed'),
      appBar: BadgeAppBar(
          title: memory.platformName,
          actions: [
            TextButton(
              child: Text('New Post +'),
              onPressed: (){
                Navigator.pushNamed(context, '/create_post');
              },
            )
          ],
      ),
      // appBar: AppBar(
      //   title: Text(memory.platformName),
      //   actions: [
      //     TextButton(
      //       child: Text('New Post +'),
      //       onPressed: (){
      //         Navigator.pushNamed(context, '/create_post');
      //       },
      //     )
      //   ],
      // ),
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
            stream: getFeed(),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Text(snapshot.error.toString());
              }else if(snapshot.hasData){
                List<Map<String, dynamic>> responses = snapshot.data!;
                feeds = responses;
                print(feeds);
                return Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: feeds.map((feedData) => FeedCard(feedData: feedData, setFeedState: setFeedState)).toList(),
                  ),
                );
              }else{
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> getFeed() async*{
    FeedModel feedModel = FeedModel();
    List<Map<String, dynamic>> offlineFeed = await feedModel.getFeedLocal();
    yield offlineFeed;
    try{
      List<Map<String, dynamic>> onlineFeed = await feedModel.getFeed();
      yield onlineFeed;
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
