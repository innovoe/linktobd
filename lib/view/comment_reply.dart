import 'package:flutter/material.dart';
import 'package:linktobd/model/feed_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/comment_card.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/reply_card.dart';
import 'package:linktobd/view/single_post.dart';

class CommentReply extends StatefulWidget {
  VoidCallback setCommentState;
  VoidCallback setFeedState;
  static void _defaultFunction() {}
  CommentReply({super.key, this.setCommentState = _defaultFunction, this.setFeedState = _defaultFunction});

  @override
  State<CommentReply> createState() => _CommentReplyState();
}

class _CommentReplyState extends State<CommentReply> {
  var replies = [];
  UniqueKey _uniqueKey = UniqueKey();
  final TextEditingController commentController = TextEditingController();
  bool isButtonActive = false; // To control button state
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to the text field changes
    commentController.addListener(() {
      final isButtonActive = commentController.text.isNotEmpty;
      setState(() => this.isButtonActive = isButtonActive); // Update the button state
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    FeedModel feedModel = FeedModel();
    return GestureDetector(
      onHorizontalDragUpdate: (details){
        if (details.primaryDelta! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        drawer: AppDrawer(currentRouteName: '/feed'),
        appBar: AppBar(
          title: Text(memory.platformName)
        ),
        body: Column(
          children: [
            SizedBox(height: 10,),
            TextButton(
              child: Text('Go back to Post'),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SinglePost(uuid: memory.postUuid),
                  ),
                );
              },
            ),
            SizedBox(height: 10,),
            FutureBuilder(
              future: feedModel.getSingleComment(),
              builder: (context, snapshot){
                print(snapshot);
                if(snapshot.hasError){
                  return Text(snapshot.error.toString());
                }else if(snapshot.hasData){
                  var sourceCommentData = snapshot.data;
                  return CommentCard(commentData: sourceCommentData, setCommentState: widget.setCommentState, doNotShowExtra: true);
                }else{
                  return CircularProgressIndicator();
                }
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Replies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Icon(Icons.arrow_right_sharp),
              ],
            ),
            SizedBox(height: 10,),
            Container(color: primaryColor, height: 1,),
            SizedBox(height: 20,),
            FutureBuilder(
              future: feedModel.getReplies(),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Text('Error');
                }else if(snapshot.hasData){
                  var responses = snapshot.data;
                  replies = responses;
                  return Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: replies.map((replyData) => ReplyCard(replyData: replyData, setReplyState: setReplyState,)).toList(),
                    ),
                  );
                }else{
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 50,),
          ],
        ),
        bottomSheet: buildBottomCommentField(),
      ),
    );
  }

  Widget buildBottomCommentField() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      // color: Colors.red, // You can style this container as needed
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: commentController,
              maxLines: null, // Makes it grow vertically
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: isButtonActive ? () => submitComment() : null,
            color: isButtonActive ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }

  void submitComment() async{
    String commentString = commentController.text;
    FocusScope.of(context).unfocus();
    commentController.clear();
    FeedModel feedModel = FeedModel();

    var response = await feedModel.addComment(commentString, '1', memory.commentId);
    if(response['success'] == 'yes'){
      CommentCard newComment = CommentCard(commentData: response, setCommentState: widget.setCommentState);
      replies.add(newComment);
      setState(() {});
    }
    Future.delayed(Duration(seconds: 1), (){
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    widget.setFeedState();
  }

  void setReplyState() {
    double currentPosition = _scrollController.offset;
    _uniqueKey = UniqueKey();
    setState(() {});
    Future.delayed(Duration(seconds: 1), (){
      _scrollController.jumpTo(currentPosition);
    });
  }
}
