import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linktobd/model/app_drawer.dart';
import 'package:linktobd/model/memory.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:dio/dio.dart';
import 'package:linktobd/model/photo_upload.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class EditPost extends StatefulWidget {
  final Map<String, dynamic> feedData;
  EditPost({Key? key, required this.feedData}) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final introKey = GlobalKey<IntroductionScreenState>();

  TextEditingController postTextController = TextEditingController();
  bool isLoading = false;
  Widget output = Text('');

  List<File> photos = [];
  bool buttonDisabled = false;

  final String imagePathPrefix = 'https://linktobd.com/assets/user_uploads/';
  List<String> photoUrls = [];
  String toBeDeleted = '';

  String uuid = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postTextController.text = widget.feedData['post_text'];
    uuid = widget.feedData['uuid'];
    // for (var photoMap in widget.feedData['photos']) {
    //   String? photo = photoMap.values.first;
    //   if (photo != null) {
    //     photoUrls.add(photo);
    //   }
    // }
    final photos = widget.feedData['photos'];
    if (photos is String) {
      // Decode only if it's a string
      photoUrls = json.decode(photos).map<String>((photo) => photo['photo'].toString()).toList();
    } else if (photos is List) {
      // Use directly if it's already a List
      photoUrls = photos.map<String>((photo) => photo['photo'].toString()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentRouteName: '/feed'),
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    maxLines: null,
                    controller: postTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Write Here',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 10,),
                    GestureDetector(
                      child: Icon(Icons.camera_alt_outlined),
                      onTap: () async{
                        PhotoUpload photoUpload = PhotoUpload();
                        File pickedFile = await photoUpload.pickImage(ImageSource.camera);
                        setState((){
                          photos.add(File(pickedFile.path));
                        });
                      },
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      child: Icon(Icons.photo),
                      onTap: () async{
                        PhotoUpload photoUpload = PhotoUpload();
                        File pickedFile = await photoUpload.pickImage(ImageSource.gallery);
                        setState((){
                          photos.add(File(pickedFile.path));
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: photoUrls.map((imageUrl) => photoView(imageUrl)).toList(),
                ),
                // ImageGrid(imageFiles: photos,),
                Column(
                  children: photos.map((imageFile) => Container(padding: EdgeInsets.all(10), child: Image.file(imageFile)),).toList(),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: Text('post'),
                      onPressed: buttonDisabled ? null :
                          () async {
                        setState(() {
                          // buttonDisabled = true;
                          output = CircularProgressIndicator();
                        });
                        if(postTextController.text.isEmpty){
                          setState(() {
                            output = Text('Please fill up both the password fields carefully.');
                          });
                        }else{
                          List<MultipartFile> imageList = [];
                          for (File photo in photos) {
                            String fileName = p.basename(photo.path);
                            MultipartFile photoFile = await MultipartFile.fromFile(photo.path, filename: fileName);
                            imageList.add(photoFile);
                          }

                          var formData = FormData();
                          formData.fields.addAll([
                            MapEntry("token", memory.token.toString()),
                            MapEntry("platform_id", memory.platformId.toString()),
                            MapEntry("post_text", postTextController.text),
                            MapEntry("uuid", uuid),
                            MapEntry("to_be_deleted", toBeDeleted),
                          ]);

                          for (var imageFile in imageList) {
                            formData.files.add(MapEntry(
                              "images[]", // This key should match the server's expected key for file uploads
                              imageFile,
                            ));
                          }
                          var dio = Dio();
                          try{
                            Response response = await dio.post(
                              'https://linktobd.com/appapi/edit_post',
                              data: formData,
                            );
                            var respond = response.data;
                            print(respond);
                            if (response.statusCode == 200) {
                              if (mounted) {
                                if (respond['success'].toString() == 'yes') {
                                  showAlertDialog(context, 'Post Saved Successfully.', 'Saved');
                                  Future.delayed(const Duration(seconds: 1)).then((val) {
                                    Navigator.pushReplacementNamed(context, '/feed');
                                  });
                                }
                              }
                            }
                          }catch (e) {
                            print(e);
                            if(mounted) {
                              showAlertDialog(context, 'An error occurred. Please try again. ${e.toString()}', 'Oops!');
                            }
                          }
                        }
                      },
                    )
                ),
                SizedBox(height: 20),
              ],
            )),
      ),
    );
  }

  Widget photoView(String imageUrl){
    return Container(
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          CachedNetworkImage(imageUrl: imagePathPrefix + imageUrl),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                photoUrls.remove(imageUrl);
                toBeDeleted = (toBeDeleted == '') ? imageUrl : '$toBeDeleted,$imageUrl';
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }


  String getFileExtension(File file) {
    // Extracting the file name from the path
    String fileName = file.path.split('/').last;

    // Extracting the extension from the file name
    String extension = '';
    if (fileName.contains('.')) {
      extension = fileName.split('.').last;
    }

    return extension; // Return the extension
  }


  void showAlertDialog(BuildContext context, String message, [String title = '']) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: title == '' ? Text('Validation Error') : Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the alert dialog
            },
          ),
        ],
      ),
    );
  }

}

