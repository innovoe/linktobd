import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linktobd/model/compress_image.dart';
import 'package:linktobd/model/memory.dart';

class AddHelpIssue extends StatefulWidget {
  VoidCallback setParentState;
  AddHelpIssue({Key? key, required this.setParentState}) : super(key: key);
  @override
  State<AddHelpIssue> createState() => _AddHelpIssueState();
}

class _AddHelpIssueState extends State<AddHelpIssue> {

  var primaryColor = Color(0xFFB533F1);
  bool isSubmitting = false;
  List<DropdownMenuItem<String>> issues = [
    DropdownMenuItem<String>(value: '', child: Text('Pick an issue')),
    DropdownMenuItem<String>(value: 'dom', child: Text('Domestic fraud or Violence')),
    DropdownMenuItem<String>(value: 'land', child: Text('Land rights or disputes')),
    DropdownMenuItem<String>(value: 'other', child: Text('Others')),
  ];

  List<File> uploadedFiles = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New issue')),
      // drawer: AppDrawer(currentRouteName: '/help_desk'),
      body: helpDeskBody(),
    );
  }


  Widget helpDeskBody() {
    TextEditingController descriptionController = TextEditingController();
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Please describe domestic fraud, violence, land rights, disputes or any kind of problem you might be facing without any hesitation. ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 30,),
            Text(
              'Upload any photos or evidence that might help.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Wrap(
              children: uploadedFiles.map((File imageFile) {
                return miniImages(imageFile);
              }).toList(),
            ),
            Row(
              children: [
                OutlinedButton(
                  child: Text('Take a new photo'),
                  onPressed: () async {
                    File? pickedFile = await pickImage(ImageSource.camera);
                    if(pickedFile != null){
                      setState(() {
                        uploadedFiles.add(pickedFile);
                      });
                    }
                  },
                ),
                SizedBox(width: 10,),
                OutlinedButton(
                  child: Text('Upload from gallery'),
                  onPressed: () async {
                    File? pickedFile = await pickImage(ImageSource.gallery);
                    if(pickedFile != null){
                      setState(() {
                        uploadedFiles.add(pickedFile);
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 30,),
            Text(
              'Please describe your issue in detail:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe your issue...',
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                isSubmitting ? (){} : submitHelp(descriptionController.text);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> submitHelp(String description) async {
    isSubmitting = true;

    if (description.length < 20) {
      // Show a warning if description is too short
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Description Too Short'),
          content: Text('Please provide a more detailed description (at least 200 characters).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'token': memory.token,
        'description': description,
        'images[]': uploadedFiles.map((file) => MultipartFile.fromFileSync(file.path)).toList(),
      });

      final response = await dio.post(
        'https://linktobd.com/appapi/create_issue',
        data: formData,
      );
      widget.setParentState();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Submission Successful'),
          content: Text('Your request has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Submission Failed'),
          content: Text('There was an error submitting your request. Please try again. $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
    isSubmitting = false;
  }



  Future<File?> pickImage(ImageSource imageSource) async{
    final ImagePicker picker = ImagePicker();
    XFile? largeImage = await picker.pickImage(source: imageSource);
    if(largeImage == null) return null;
    XFile? compressFile = await compressImage(largeImage, 25);
    File outputCompressFile = File(compressFile.path);
    File(largeImage.path).deleteSync();
    return outputCompressFile;
  }

  Widget miniImages(File imageFile) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () {
          // Make the image bigger
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: Image.file(imageFile),
            ),
          );
        },
        onLongPress: () {
          // Delete the image from the row
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Delete Image'),
                content: Text('Are you sure you want to delete this image?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        uploadedFiles.remove(imageFile);
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        child: Image.file(imageFile, height: 100),
      ),
    );
  }

}
