import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/custom_page_route_animator.dart';
import 'package:link2bd/model/feed_card_images.dart';
import 'package:link2bd/model/memory.dart';
import 'package:link2bd/view/comment_reply.dart';
import 'package:link2bd/view/post_comment.dart';

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> commentData;
  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';

  CommentCard({required this.commentData});

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
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    'https://linktobd.com/assets/user_dp/thumbs/${commentData['commenting_user_photo']}',
                  ),
                  radius: 20.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commentData['commenting_user'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(commentData['comment']),
                      SizedBox(height: 10,),
                      Text(commentData['date']),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${commentData['like_count']} likes'),
                (commentData['type'] == '0') ?
                GestureDetector(
                  child: Text('${commentData['reply_count']} replies'),
                  onTap: (){
                    memory.commentId = commentData['comment_id'];
                    Navigator.of(context).push(
                        CustomPageRouteAnimator(child: CommentReply(), direction: 'fromRight')
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
}
