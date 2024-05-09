import 'package:flutter/material.dart';
import 'package:link2bd/model/app_drawer.dart';
import 'package:link2bd/model/comment_card.dart';
import 'package:link2bd/model/feed_model.dart';
import 'package:link2bd/model/widgets.dart';

class EditComment extends StatefulWidget {
  final Map<String, dynamic> commentData;
  VoidCallback setCommentState;
  VoidCallback setReplyState;
  static void _defaultFunction() {}
  EditComment({super.key, required this.commentData, required this.setCommentState, this.setReplyState=_defaultFunction});

  @override
  State<EditComment> createState() => _EditCommentState();
}

class _EditCommentState extends State<EditComment> {

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
    commentController.text = widget.commentData['comment'];
  }

  @override
  void dispose() {
    commentController.dispose(); // Dispose controller when widget is removed
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/feed'),
      appBar: AppBar(
        title: Text('Edit Comment'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: 10,),
          CommentCard(commentData: widget.commentData, setCommentState: widget.setCommentState, doNotShowExtra: true),
          SizedBox(height: 10,),
          Container(color: primaryColor, height: 1,),
          SizedBox(height: 20,),
          Row(
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
        ],
      ),
    );
  }

  void submitComment() async{
    String commentString = commentController.text;
    FocusScope.of(context).unfocus();
    commentController.clear();
    FeedModel feedModel = FeedModel();
    try{
      var response = await feedModel.editComment(commentString, widget.commentData['comment_id']);
      print(widget.commentData['comment_id']);
      if(response['success'] == 'yes'){

        widget.setCommentState();
        widget.setReplyState();
        Future.delayed(Duration(milliseconds: 500), (){
          Navigator.pop(context);
        });
      }else{
        showAlertDialog(context, 'An error occurred. Please try again.', 'Edit Error');
      }
    }catch(e){
      showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}', 'Edit Error');
    }
  }
}
