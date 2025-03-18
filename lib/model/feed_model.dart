import 'dart:convert';
import 'package:linktobd/model/db_manager.dart';
import 'package:linktobd/model/memory.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class FeedModel{

  final String key1 = 'dontyoucryurikufiaddontyoucryurikufiad';
  final String key2 = 'letsgoyeahcomeoncomeonturntheradioonitsfrydaynight';
  final String clientUrl = 'https://linktobd.com/appapi/app_login';



  Future<List<Map<String, dynamic>>> getFeed() async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'platform_id' : memory.platformId.toString()});
    Dio dio = Dio();
    var responses = await dio.post(
      'https://linktobd.com/appapi/feed',
      data: formData,
    );

    List<Map<String, dynamic>> feeds = [];
    for (var response in responses.data) {
      var photos = [];
      for (var photoResponse in response['photos']) {
        Map<String, dynamic> photo = {'photo': photoResponse.toString()};
        photos.add(photo);
      }
      var feed = {
        // 'user_id': 0,
        'nickname': response['nickname'].toString(),
        'user_name': response['user_name'].toString(),
        'user_photo': response['user_photo'].toString(),
        'post_time': response['post_time'].toString(),
        'post_text': response['post_text'].toString(),
        'nickname': response['nickname'].toString(),
        'photos': photos,
        'like': response['like'].toString(),
        'like_count': response['like_count'].toString(),
        'dislike': response['dislike'].toString(),
        'dislike_count': response['dislike_count'].toString(),
        'comment_count': response['comment_count'].toString(),
        'post_id': response['post_id'].toString(),
        'uuid': response['uuid'].toString(),
        'own': response['own'].toString(),
        'platform_id': response['platform_id'].toString()
      };
      feeds.add(feed);
    }
    List<Map<String, dynamic>> feedLocal = feeds;
    await clearFeedLocal();
    await saveFeedLocal(feedLocal);
    return feeds;

  }

  Future<void> clearFeedLocal() async{
    DbManager dbManager = DbManager();
    try{
      await dbManager.deleteRows('feeding', 'platform_id = ?', [memory.platformId]);
    }catch (e){
      await dbManager.dropTable('feeding');
    }
  }


  Future<void> saveFeedLocal(List<Map<String, dynamic>> feeds) async {
    DbManager dbManager = DbManager();
    // Define the columns based on your database schema for the 'feeds' table
    List<String> columns = [
      'id','nickname',
      'user_name', 'user_photo', 'post_time', 'post_text',
      'photos', 'like', 'like_count', 'dislike',
      'dislike_count', 'comment_count', 'post_id', 'uuid', 'own', 'platform_id'
    ];

    // Serialize the 'photos' list to a JSON string for each feed
    List<Map<String, dynamic>> serializedFeeds = feeds.map((feed) {
      if (feed.containsKey('photos') && feed['photos'] is List) {
        // Convert the 'photos' List to a JSON string
        feed['photos'] = json.encode(feed['photos']);
      }
      return feed;
    }).toList();
    DbTable feedTable = DbTable(tableName: 'feeding', columns: columns, rows: serializedFeeds);

    await dbManager.ensureTableExists(feedTable);
    await dbManager.sync(feedTable);
  }

  Future<List<Map<String, dynamic>>> getFeedLocal() async {
    try{
      DbManager dbManager = DbManager();

      // Ensure 'feeding' table exists before querying
      await dbManager.ensureTableExists(DbTable(
          tableName: 'feeding',
          columns: [
            'id', 'nickname', 'user_name', 'user_photo', 'post_time', 'post_text',
            'photos', 'like', 'like_count', 'dislike',
            'dislike_count', 'comment_count', 'post_id', 'uuid', 'own', 'platform_id'
          ]
      ));

      // Proceed with fetching data after the table is confirmed to exist
      List<Map<String, dynamic>> feeds = await dbManager.getData(
          'feeding',
          'post_time',
          where: 'platform_id = ?',
          whereArgs: [memory.platformId]
      );

      // Process and deserialize 'photos' JSON
      List<Map<String, dynamic>> mutableFeeds = feeds.map((feed) {
        Map<String, dynamic> mutableFeed = Map<String, dynamic>.from(feed);
        if (mutableFeed['photos'] is String) {
          try {
            mutableFeed['photos'] = json.decode(mutableFeed['photos']);
          } catch (e) {
            print('Error decoding photos JSON: $e');
            mutableFeed['photos'] = [];
          }
        }
        return mutableFeed;
      }).toList();

      return mutableFeeds;
    }catch (e){
      await clearFeedLocal();
      return [];
    }

  }



  Future<Map<String, dynamic>> getSinglePost(String uuid) async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'uuid' : uuid});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/single_post',
      data: formData,
    );
    var responseArray = responses.data;
    var response = responseArray[0];
    var photos = [];
    for (var photoResponse in response['photos']) {
      Map<String, dynamic> photo = {'photo': photoResponse.toString()};
      photos.add(photo);
    }
    Map<String, dynamic> feed = {
      // 'user_id': 0,
      'user_name': response['user_name'].toString(),
      'nickname': response['nickname'].toString(),
      'user_photo': response['user_photo'].toString(),
      'post_time': response['post_time'].toString(),
      'post_text': response['post_text'].toString(),
      'photos': photos,
      'like': response['like'].toString(),
      'like_count': response['like_count'].toString(),
      'dislike': response['dislike'].toString(),
      'dislike_count': response['dislike_count'].toString(),
      'comment_count': response['comment_count'].toString(),
      'post_id': response['post_id'].toString(),
      'uuid': response['uuid'].toString(),
      'own': response['own'].toString(),
      'platform_id': response['platform_id'].toString()
    };
    return feed;
  }






  Future<dynamic> getComments() async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'post_id' : memory.postId});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/comments',
      data: formData,
    );
    // print(response.data.toString());
    var comments = [];
    for(var response in responses.data){

      var comment = {
        'nickname': response['nickname'].toString(),
        'commenting_user': response['commenting_user'].toString(),
        'commenting_user_photo': response['commenting_user_photo'].toString(),
        'date': response['date'].toString(),
        'type': response['type'].toString(),
        'comment': response['comment'].toString(),
        'like': response['like'].toString(),
        'like_count': response['like_count'].toString(),
        'dislike': response['dislike'].toString(),
        'dislike_count': response['dislike_count'].toString(),
        'reply': response['reply'].toString(),
        'reply_count': response['reply_count'].toString(),
        'comment_id' : response['comment_id'].toString(),
        'uuid' : response['uuid'].toString(),
        'own' : response['own'].toString()
      };
      comments.add(comment);
    }
    return comments;
  }

  Future<dynamic> getSingleComment() async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'comment_id' : memory.commentId.toString()});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/single_comment',
      data: formData,
    );
    var responseArray = responses.data;
    var response = responseArray[0];
    // print(response);
    var comment = {
      'nickname': response['nickname'].toString(),
      'commenting_user': response['commenting_user'].toString(),
      'commenting_user_photo': response['commenting_user_photo'].toString(),
      'date': response['date'].toString(),
      'type': response['type'].toString(),
      'comment': response['comment'].toString(),
      'like': response['like'].toString(),
      'like_count': response['like_count'].toString(),
      'dislike': response['dislike'].toString(),
      'dislike_count': response['dislike_count'].toString(),
      'reply': response['reply'].toString(),
      'reply_count': response['reply_count'].toString(),
      'comment_id' : response['comment_id'].toString(),
      'uuid' : response['uuid'].toString(),
      'own' : response['own'].toString()
    };


    return comment;
  }


  Future<dynamic> getReplies() async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'parent_comment_id' : memory.commentId});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/replies',
      data: formData,
    );
    var comments = [];
    for(var response in responses.data){
      var comment = {
        'nickname': response['nickname'].toString(),
        'commenting_user': response['commenting_user'].toString(),
        'commenting_user_photo': response['commenting_user_photo'].toString(),
        'date': response['date'].toString(),
        'type': response['type'].toString(),
        'comment': response['comment'],
        'like': response['like'].toString(),
        'like_count': response['like_count'].toString(),
        'dislike': response['dislike'].toString(),
        'dislike_count': response['dislike_count'].toString(),
        // 'reply_count': response['reply_count'].toString(),
        'comment_id' : response['comment_id'].toString(),
        'uuid' : response['uuid'].toString(),
        'own' : response['own'].toString()
      };
      comments.add(comment);
    }
    return comments;
  }

  Future<dynamic> addComment(String commentString, String type, String parentCommentId) async{
    Uuid uuid = Uuid();
    FormData formData = FormData.fromMap({
      'token' : memory.token,
      'post_id' : memory.postId,
      'comment' : commentString,
      'type' : type,
      'parent_comment_id' : parentCommentId,
      'uuid' : uuid.v1().toString()
    });
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/create_comment',
      data: formData,
    );
    return responses.data;
  }

  Future<dynamic> editComment(String commentString, String comment_id) async{
    FormData formData = FormData.fromMap({
      'token' : memory.token,
      'comment_text' : commentString,
      'comment_id' : comment_id
    });
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/edit_comment',
      data: formData,
    );
    return responses.data;
  }

}