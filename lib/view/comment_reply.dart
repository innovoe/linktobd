import 'package:flutter/material.dart';
import 'package:link2bd/model/feed_model.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/comment_card.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/reply_card.dart';

class CommentReply extends StatefulWidget {
  const CommentReply({super.key});

  @override
  State<CommentReply> createState() => _CommentReplyState();
}

class _CommentReplyState extends State<CommentReply> {
  var replies = [];

  final TextEditingController commentController = TextEditingController();
  bool isButtonActive = false; // To control button state

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
    commentController.dispose(); // Dispose controller when widget is removed
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
          title: Text(memory.platformName),
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
            SizedBox(height: 10,),
            FutureBuilder(
              future: feedModel.getSingleComment(),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  print(snapshot.error);
                  return Text(snapshot.error.toString());
                }else if(snapshot.hasData){
                  var sourceCommentData = snapshot.data;
                  return CommentCard(commentData: sourceCommentData);
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
                      children: replies.map((replyData) => ReplyCard(replyData: replyData)).toList(),
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
      CommentCard newComment = CommentCard(commentData: response);
      replies.add(newComment);
      setState(() {});
    }
  }
}
