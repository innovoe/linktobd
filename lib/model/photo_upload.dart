import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUpload{

  Future<XFile?> pickImage(ImageSource imageSource) async{
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: imageSource);
  }


}