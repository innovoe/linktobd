import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/widgets.dart';
//will work on this later
class LikeDislikeModel{

  VoidCallback setState;


  bool liked = false;
  int likeCount = 0;

  bool disliked = false;
  int dislikeCount = 0;

  bool isAnimatingDislike = false;
  bool isAnimatingLike = false;
  int commentId;
  BuildContext context;
  LikeDislikeModel({
    required this.context,
    required this.liked,
    required this.likeCount,
    required this.disliked,
    required this.dislikeCount,
    required this.commentId,
    required this.setState
  });

  Widget likeDislikeWidget(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$likeCount ', style: TextStyle(fontSize: 16),),
        GestureDetector(
          child: AnimatedContainer(
            child: (liked == true) ? Icon(size: 20, Icons.thumb_up, color: Colors.purple) : Icon(size: 20, Icons.thumb_up_alt_outlined),
            duration: Duration(milliseconds: 300),
            transform: Matrix4.diagonal3Values(isAnimatingLike ? 2 : 1.0, isAnimatingLike ? 2 : 1.0, 1.0),
          ),
          onTap: () async{
            // setState(() {
            //   isAnimatingLike = true;
            // });
            // likeDislikeUpdater('like');
            // await Future.delayed(Duration(milliseconds: 300));
            // setState(() {
            //   isAnimatingLike = false;
            // });

            var dio = Dio();
            FormData formData = FormData.fromMap({
              'token' : memory.token,
              'comment_id' : commentId
            });
            try{
              Response response = await dio.post(
                'https://linktobd.com/appapi/do_like',
                data: formData,
              );
              var respond = response.data;
              if (response.statusCode == 200) {
                if (respond['success'].toString() == 'yes') {

                }
              }
            }catch (e) {
              likeDislikeUpdater('like');
              // setState(() {});
              showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}', '');
            }
          },
        ),
        SizedBox(width: 15,),
        Text('$dislikeCount ', style: TextStyle(fontSize: 16),),
        GestureDetector( //dislike
          child: AnimatedContainer(
            child: (disliked == true) ? Icon(size: 20, Icons.thumb_down, color: Colors.purple) : Icon(size: 20, Icons.thumb_down_alt_outlined),
            duration: Duration(milliseconds: 300),
            transform: Matrix4.diagonal3Values(isAnimatingDislike ? 2 : 1.0, isAnimatingDislike ? 2 : 1.0, 1.0),
          ),
          onTap: () async{
            // setState(() {
            //   isAnimatingDislike = true;
            // });
            // likeDislikeUpdater('dislike');
            // await Future.delayed(Duration(milliseconds: 300));
            // setState(() {
            //   isAnimatingDislike = false;
            // });
            var dio = Dio();
            FormData formData = FormData.fromMap({
              'token' : memory.token,
              'comment_id' : commentId
            });
            try{
              Response response = await dio.post(
                'https://linktobd.com/appapi/do_dislike',
                data: formData,
              );
              var respond = response.data;
              if (response.statusCode == 200) {
                if (respond['success'].toString() == 'yes') {

                }
              }
            }catch (e) {
              likeDislikeUpdater('dislike');
              // setState(() {});
              showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}', '');
            }
          },
        )
      ],
    );
  }

  void likeDislikeUpdater(String mode){
    if(mode == 'like'){
      if(liked == true){
        liked = false;
        likeCount = likeCount -1;
      }else {
        liked = true;
        likeCount = likeCount + 1;
        if(disliked == true){
          disliked = false;
          dislikeCount = dislikeCount - 1;
        }
      }
    }

    if(mode == 'dislike'){
      if(disliked == true){
        disliked = false;
        dislikeCount = dislikeCount -1;
      }else {
        disliked = true;
        dislikeCount = dislikeCount + 1;
        if(liked == true){
          liked = false;
          likeCount = likeCount - 1;
        }
      }
    }
  }
}