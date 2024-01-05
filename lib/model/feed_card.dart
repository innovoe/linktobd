import 'package:flutter/material.dart';
import 'package:link2bd/model/feed_card_images.dart';

class FeedCard extends StatelessWidget {
  final Map<String, dynamic> feedData;
  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';

  FeedCard({required this.feedData});

  @override
  Widget build(BuildContext context) {
    List<String> photoUrls = [];
    for (var photoMap in feedData['photos']) {
      String? photo = photoMap.values.first;
      if (photo != null) {
        photoUrls.add(imagePathPrefix + photo);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(imagePathPrefix + feedData['user_photo']),
                  radius: 20.0,
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedData['user_name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(feedData['post_time']),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if(feedData['post_text'] != null && feedData['post_text'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(feedData['post_text']),
            ),
          if(photoUrls.isNotEmpty) FeedCardImages(imageUrls: photoUrls),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${feedData['like_count']} likes'),
                Text('${feedData['comment_count']} comments'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
