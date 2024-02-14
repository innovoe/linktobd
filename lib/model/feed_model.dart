import 'package:link2bd/model/memory.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class FeedModel{

  final String key1 = 'dontyoucryurikufiaddontyoucryurikufiad';
  final String key2 = 'letsgoyeahcomeoncomeonturntheradioonitsfrydaynight';
  final String clientUrl = 'https://linktobd.com/appapi/app_login';


  Future<dynamic> getFeed() async{
    FormData formData = FormData.fromMap({'token' : memory.token, 'platform_id' : memory.platformId.toString()});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/feed',
      data: formData,
    );
    var feeds = [];
    for(var response in responses.data){
      var photos = [];
      int photoSerial = 0;
      for(var photoResponse in response['photos']){
        var photo = {photoSerial:photoResponse.toString()};
        photoSerial++;
        photos.add(photo);
      }
      var feed = {
        'user_id':0,
        'user_name': response['user_name'].toString(),
        'user_photo': response['user_photo'].toString(),
        'post_time': response['post_time'].toString(),
        'post_text': response['post_text'].toString(),
        'photos': photos,
        'like': response['like'].toString(),
        'like_count': response['like_count'].toString(),
        'dislike': response['dislike'].toString(),
        'dislike_count': response['dislike_count'].toString(),
        'comment_count': response['comment_count'].toString(),
        'post_id' : response['post_id'].toString(),
        'uuid' : response['uuid'].toString(),
        'own' : response['own'].toString()
      };
      feeds.add(feed);
    }
    return feeds;
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
        'commenting_user': response['commenting_user'].toString(),
        'commenting_user_photo': response['commenting_user_photo'].toString(),
        'date': response['date'].toString(),
        'type': response['type'].toString(),
        'comment': response['comment'],
        'like_count': response['like_count'].toString(),
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
    FormData formData = FormData.fromMap({'token' : memory.token, 'comment_id' : memory.commentId});
    Dio dio = Dio();
    Response responses = await dio.post(
      'https://linktobd.com/appapi/single_comment',
      data: formData,
    );
    var response = responses.data;

    // print(response.toString());

    var comment = {
      'commenting_user': response['commenting_user'].toString(),
      'commenting_user_photo': response['commenting_user_photo'].toString(),
      'date': response['date'].toString(),
      'type': response['type'].toString(),
      'comment': response['comment'],
      'like_count': response['like_count'].toString(),
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
        'commenting_user': response['commenting_user'].toString(),
        'commenting_user_photo': response['commenting_user_photo'].toString(),
        'date': response['date'].toString(),
        'type': response['type'].toString(),
        'comment': response['comment'],
        'like_count': response['like_count'].toString(),
        'reply_count': response['reply_count'].toString(),
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

}