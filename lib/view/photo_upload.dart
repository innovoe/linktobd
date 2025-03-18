import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linktobd/model/compress_image.dart';
import 'package:linktobd/model/memory.dart';
import 'package:linktobd/model/widgets.dart';


class PhotoUpload extends StatefulWidget {
  VoidCallback setProfileState;
  PhotoUpload({super.key, required this.setProfileState});

  @override
  State<PhotoUpload> createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  File? selectedImage;
  bool working = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Upload'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (selectedImage == null) ? Image.asset('assets/default_dp.jpg') : Image.file(selectedImage!),
            SizedBox(height: 30,),
            Row(
              children: [
                OutlinedButton(
                  child: Text('Take a new photo'),
                  onPressed: () async{
                    File pickedFile = await pickImage(ImageSource.camera);
                    setState((){
                      selectedImage = File(pickedFile.path);
                    });
                  },
                ),
                OutlinedButton(
                  child: Text('Upload from gallery'),
                  onPressed: () async{
                    File pickedFile = await pickImage(ImageSource.gallery);
                    setState((){
                      selectedImage = File(pickedFile.path);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 30,),
            selectedImage != null ? (working ? CircularProgressIndicator() :uploadButton()) : Container()
          ],
        ),
      ),
    );
  }


  Widget uploadButton(){
    return ElevatedButton(
      child: Text('Upload'),
      onPressed: ()async{
        setState(() {
          working = true;
        });
        FormData formData = FormData.fromMap({
          'token': memory.token,
          'photo': selectedImage != null ? await MultipartFile.fromFile(selectedImage!.path) : null,
        });
        print(selectedImage!.path);
        try{
          Dio dio = Dio();
          var response = await dio.post('https://linktobd.com/appapi/profile_photo_upload', data: formData);
          if(response.statusCode == 200){
            var responseData = response.data;
            if(responseData['success'].toString() == 'yes'){
              setState(() {working = false;});
              widget.setProfileState();
              Navigator.pop(context);
            }

            // Navigator.pop(context);
          }else{
            setState(() {working = false;});
            showAlertDialog(context, 'Failed to upload image', 'Image upload');
          }
        }catch(e){
          setState(() {working = false;});
          showAlertDialog(context, 'Failed to upload image: $e', 'Image upload');
        }
      },
    );
  }

  Future<File> pickImage(ImageSource imageSource) async{
    final ImagePicker picker = ImagePicker();
    XFile? largeImage = await picker.pickImage(source: imageSource);
    XFile? compressFile = await compressImage(largeImage!, 25);
    Directory largeImageDirectory = Directory(largeImage.path);
    largeImageDirectory.deleteSync(recursive: true);
    File outputCompressFile = File(compressFile.path);
    return outputCompressFile;
  }
}
