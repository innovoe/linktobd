import 'dart:io';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<File> imageFiles;

  const ImageGrid({super.key, required this.imageFiles});

  @override
  Widget build(BuildContext context) {
    if (imageFiles.isEmpty) {
      return Center(
        child: Text('No images available'),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust the number of images per row
        childAspectRatio: 1.0, // Optionally adjust to fit your aspect ratio needs
      ),
      itemCount: imageFiles.length,
      itemBuilder: (context, index) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: 200, // Max height for each image
            maxWidth: 200, // Max width for each image
          ),
          padding: EdgeInsets.all(8), // Add padding if needed
          child: Image.file(
            imageFiles[index],
            fit: BoxFit.contain, // Maintains the aspect ratio of the image
          ),
        );
      },
    );
  }
}
