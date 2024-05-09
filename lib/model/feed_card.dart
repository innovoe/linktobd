import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/custom_page_route_animator.dart';
import 'package:link2bd/model/feed_card_images.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/model/relative_timestamp.dart';
import 'package:link2bd/view/edit_post.dart';
import 'package:link2bd/view/post_comment.dart';
import 'package:link2bd/model/widgets.dart';
import 'package:link2bd/view/single_post.dart';

class FeedCard extends StatefulWidget {
  VoidCallback setFeedState;
  final Map<String, dynamic> feedData;

  FeedCard({required this.feedData, required this.setFeedState});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';

  bool liked = false;
  int likeCount = 0;

  bool disliked = false;
  int dislikeCount = 0;

  bool isAnimatingDislike = false;
  bool isAnimatingLike = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    liked = (widget.feedData['like'] == 'yes') ? true : false;
    likeCount = int.parse(widget.feedData['like_count']);
    disliked = (widget.feedData['dislike'] == 'yes') ? true : false;
    dislikeCount = int.parse(widget.feedData['dislike_count']);
  }

  @override
  Widget build(BuildContext context) {
    List<String> photoUrls = [];
    // for (var photoMap in widget.feedData['photos']) {
    //   String? photo = photoMap.values.first;
    //   if (photo != null) {
    //     photoUrls.add(imagePathPrefix + photo);
    //   }
    // }

    // List<dynamic> photos = json.decode(widget.feedData['photos']);
    // photoUrls = photos.map<String>((photo) => imagePathPrefix + photo['photo']).toList();

    final photos = widget.feedData['photos'];
    if (photos is String) {
      // Decode only if it's a string
      photoUrls = json.decode(photos).map<String>((photo) => imagePathPrefix + photo['photo']).toList();
    } else if (photos is List) {
      // Use directly if it's already a List
      photoUrls = photos.map<String>((photo) => imagePathPrefix + photo['photo']).toList();
    }

    return Card(
      margin: const EdgeInsets.only(bottom:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                  CustomPageRouteAnimator(child: SinglePost(uuid: '${widget.feedData['uuid']}'), direction: 'fromTop')
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      'https://linktobd.com/assets/user_dp/thumbs/${widget.feedData['user_photo']}',
                    ),
                    radius: 20.0,
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.feedData['user_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text(widget.feedData['post_time']),
                        RelativeTimestamp(timestamp: widget.feedData['post_time']),
                      ],
                    ),
                  ),
                  widget.feedData['own'].toString() == 'yes' ? GestureDetector(
                    onTap: (){
                      return settingButtonAlert(context, [
                        TextButton(
                          child: Text('Edit'),
                          onPressed: (){
                            Navigator.of(context).pushReplacement(
                                CustomPageRouteAnimator(child: EditPost(feedData: widget.feedData), direction: 'fromTop')
                            );
                          },
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () async{
                            var dio = Dio();
                            FormData formData = FormData.fromMap({
                              'token' : memory.token,
                              'uuid' : widget.feedData['uuid'],
                              'post_id' : widget.feedData['post_id']
                            });
                            try{
                              Response response = await dio.post(
                                'https://linktobd.com/appapi/delete_post',
                                data: formData,
                              );
                              var respond = response.data;
                              if (response.statusCode == 200) {
                                if (respond['success'].toString() == 'yes') {
                                  showAlertDialog(context, 'Post Remove Successfully.', 'Delete Complete');
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
          ),
          if(widget.feedData['post_text'] != null && widget.feedData['post_text'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(widget.feedData['post_text']),
            ),
          if(photoUrls.isNotEmpty) FeedCardImages(imageUrls: photoUrls),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                likeDislikeWidget(),
                GestureDetector(
                  child: Text('${widget.feedData['comment_count']} comments'),
                  onTap: (){
                    memory.postId = widget.feedData['post_id'];
                    Navigator.of(context).push(
                      CustomPageRouteAnimator(child: PostComment(setFeedState: widget.setFeedState,), direction: 'fromRight')
                    );
                  },
                ),
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
              'uuid' : widget.feedData['uuid'],
              'post_id' : widget.feedData['post_id']
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
              'uuid' : widget.feedData['uuid'],
              'post_id' : widget.feedData['post_id']
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


}
