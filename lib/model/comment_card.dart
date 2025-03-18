import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:linktobd/model/custom_page_route_animator.dart';
import 'package:linktobd/model/feed_card_images.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/relative_timestamp.dart';
import 'package:linktobd/view/comment_reply.dart';
import 'package:linktobd/view/edit_comment.dart';
import 'package:linktobd/view/post_comment.dart';
import 'package:linktobd/model/widgets.dart';
import 'package:linktobd/view/user_profile.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> commentData;
  VoidCallback setCommentState;
  bool doNotShowExtra;
  VoidCallback setFeedState;
  static void _defaultFunction() {}
  CommentCard({
    required this.commentData,
    required this.setCommentState,
    this.doNotShowExtra = false,
    this.setFeedState = _defaultFunction
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';

  bool liked = false;
  int likeCount = 0;

  bool disliked = false;
  int dislikeCount = 0;

  bool isAnimatingDislike = false;
  bool isAnimatingLike = false;

  int replyCount = 0;

  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    liked = (widget.commentData['like'] == 'yes') ? true : false;
    likeCount = int.parse(widget.commentData['like_count']);
    disliked = (widget.commentData['dislike'] == 'yes') ? true : false;
    dislikeCount = int.parse(widget.commentData['dislike_count']);
    replyCount = int.parse(widget.commentData['reply_count'].toString());
    loopMetaCounts();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(bottom:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      CustomPageRouteAnimator(child: UserProfile(nickname: '${widget.commentData['nickname']}'), direction: 'fromRight')
                  ),
                  behavior: HitTestBehavior.translucent,
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://linktobd.com/assets/user_dp/thumbs/${widget.commentData['commenting_user_photo']}',
                    ),
                    radius: 20.0,
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.commentData['commenting_user'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.commentData['comment']),
                      SizedBox(height: 10,),
                      RelativeTimestamp(timestamp: widget.commentData['date']),
                    ],
                  ),
                ),
                widget.commentData['own'].toString() == 'yes' && widget.doNotShowExtra == false ? GestureDetector(
                  onTap: (){
                    return settingButtonAlert(context, [
                      TextButton(
                        child: Text('Edit'),
                        onPressed: (){
                          Navigator.of(context).pushReplacement(
                              CustomPageRouteAnimator(child: EditComment(commentData: widget.commentData, setCommentState: widget.setCommentState), direction: 'fromTop')
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () async{
                          var dio = Dio();
                          FormData formData = FormData.fromMap({
                            'token' : memory.token,
                            'uuid' : widget.commentData['uuid'],
                            'comment_id' : widget.commentData['comment_id']
                          });
                          try{
                            Response response = await dio.post(
                              'https://linktobd.com/appapi/delete_comment',
                              data: formData,
                            );
                            var respond = response.data;
                            if (response.statusCode == 200) {
                              if (respond['success'].toString() == 'yes') {
                                showAlertDialog(context, 'Your comment removed from the post.', 'Delete Complete');
                                Future.delayed(const Duration(seconds: 1)).then((val) {
                                  Navigator.pushReplacementNamed(context, '/feed');
                                });
                              }
                            }
                          }catch (e) {
                            showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}', '');
                          }
                        },
                      )
                    ]);
                  },
                  child: Icon(Icons.settings),
                ) : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                likeDislikeWidget(),
                (widget.commentData['type'] == '0') && widget.doNotShowExtra == false ?
                GestureDetector(
                  child: Text('$replyCount replies'),
                  onTap: (){
                    memory.commentId = widget.commentData['comment_id'];
                    Navigator.of(context).push(
                        CustomPageRouteAnimator(child: CommentReply(setCommentState: widget.setCommentState, setFeedState: widget.setFeedState), direction: 'fromRight')
                    );
                  },
                ) : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            setState(() {
              isAnimatingLike = true;
            });
            likeDislikeUpdater('like');
            await Future.delayed(Duration(milliseconds: 300));
            setState(() {
              isAnimatingLike = false;
            });

            var dio = Dio();
            FormData formData = FormData.fromMap({
              'token' : memory.token,
              'comment_id' : widget.commentData['comment_id']
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
              setState(() {});
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
            setState(() {
              isAnimatingDislike = true;
            });
            likeDislikeUpdater('dislike');
            await Future.delayed(Duration(milliseconds: 300));
            setState(() {
              isAnimatingDislike = false;
            });
            var dio = Dio();
            FormData formData = FormData.fromMap({
              'token' : memory.token,
              'comment_id' : widget.commentData['comment_id']
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
              setState(() {});
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

  Future<void> loopMetaCounts() async {
    Duration getRandomDuration() {
      final random = Random();
      // Generate a random number between 20100 and 40,000 milliseconds (20.1 to 40.0 seconds)
      final milliseconds = 20100 + random.nextInt(40000 - 20100 + 1);
      return Duration(milliseconds: milliseconds);
    }
    timer = Timer.periodic(getRandomDuration(), (timer) async {
      var dio = Dio();
      FormData formData = FormData.fromMap({
        'token' : memory.token,
        'comment_id' : widget.commentData['comment_id']
      });
      Response response = await dio.post(
        'https://linktobd.com/appapi/meta_counts',
        data: formData,
      );
      var respond = response.data;
      if (response.statusCode == 200) {
        if (respond['success'].toString() == 'yes') {
          liked = (respond['like'].toString() == 'yes') ? true : false;
          likeCount = int.parse(respond['like_count'].toString());
          disliked = (respond['dislike'].toString() == 'yes') ? true : false;
          dislikeCount = int.parse(respond['dislike_count'].toString());
          replyCount = int.parse(respond['reply_count'].toString());
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}
