import 'package:flutter/material.dart';
import 'package:linktobd/model/feed_model.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/comment_card.dart';
import 'package:linktobd/model/app_drawer.dart';

class PostCommentDirect extends StatefulWidget {
  const PostCommentDirect({super.key});

  @override
  State<PostCommentDirect> createState() => _PostCommentDirectState();
}

class _PostCommentDirectState extends State<PostCommentDirect> {
  var comments = [];
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
    _scrollController.dispose();
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
            title: Text(memory.platformName)
        ),
        body: Column(
          children: [
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Icon(Icons.arrow_right_sharp),
              ],
            ),
            SizedBox(height: 10,),
            Container(color: primaryColor, height: 1,),
            SizedBox(height: 20,),
            FutureBuilder(
              future: feedModel.getComments(),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Text('Error : ${snapshot.error.toString()}');
                }else if(snapshot.hasData){
                  var responses = snapshot.data;
                  comments = responses;
                  // print(comments);
                  return Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: comments.map((commentData) => CommentCard(commentData: commentData, setCommentState: setCommentState, setFeedState: (){})).toList(),
                    ),
                  );
                }else{
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 50,)
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
    var response = await feedModel.addComment(commentString, '0', '0');
    if(response['success'] == 'yes'){
      CommentCard newComment = CommentCard(commentData: response, setCommentState: setCommentState);
      comments.add(newComment);
      setState(() {});
    }
    Future.delayed(Duration(seconds: 1), (){
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void setCommentState() {
    double currentPosition = _scrollController.offset;
    _uniqueKey = UniqueKey();
    setState(() {});
    Future.delayed(Duration(seconds: 1), (){
      _scrollController.jumpTo(currentPosition);
    });
  }

}
