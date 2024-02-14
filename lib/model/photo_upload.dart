import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUpload{

  Future<File> pickImage(ImageSource imageSource) async{
    final ImagePicker picker = ImagePicker();
    XFile? largeImage = await picker.pickImage(source: imageSource);
    File compressFile = await FlutterNativeImage.compressImage(
      largeImage!.path,
      quality: 25
    );
    Directory largeImageDirectory = Directory(largeImage!.path);
    largeImageDirectory.deleteSync(recursive: true);
    return compressFile;
  }


}