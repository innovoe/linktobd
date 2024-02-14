import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link2bd/model/custom_page_route_animator.dart';
import 'package:link2bd/model/memory.dart';

class ReplyCard extends StatelessWidget {
  final Map<String, dynamic> replyData;
  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';

  ReplyCard({required this.replyData});

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
                    'https://linktobd.com/assets/user_dp/thumbs/${replyData['commenting_user_photo']}',
                  ),
                  radius: 20.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replyData['commenting_user'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(replyData['comment']),
                      SizedBox(height: 10,),
                      Text(replyData['date']),
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
                Text('${replyData['like_count']} likes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
