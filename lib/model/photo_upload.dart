import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:linktobd/model/compress_image.dart';

class PhotoUpload{

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