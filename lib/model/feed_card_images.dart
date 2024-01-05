import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FeedCardImages extends StatelessWidget {
  final List<String> imageUrls;


  FeedCardImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    double viewportHeight = MediaQuery.of(context).size.height;
    double calculatedHeight = viewportHeight * 0.25;
    double imageHeight = calculatedHeight < 200 ? 200 : calculatedHeight;

    if (imageUrls.isEmpty) return Container();

    void _openImageFullScreen(int initialPage) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageFullScreen(imageUrls: imageUrls, initialPage: initialPage),
      ));
    }

    Widget _buildImage(String imageUrl, double widthFraction, int index) {
      return GestureDetector(
        onTap: () => _openImageFullScreen(index),
        child: Container(
          width: widthFraction,
          height: imageHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }


    List<Widget> _buildImages() {
      switch (imageUrls.length) {
        case 1:
          return [_buildImage(imageUrls[0], double.infinity, 0)];
        case 2:
          return [
            Row(
              children: imageUrls.asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key)).toList(),
            ),
          ];
        case 3:
          return [
            _buildImage(imageUrls[0], double.infinity, 0),
            Row(
              children: imageUrls.sublist(1).asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key + 1)).toList(),
            ),
          ];
        case 4:
          return [
            Row(
              children: imageUrls.sublist(0, 2).asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key)).toList(),
            ),
            Row(
              children: imageUrls.sublist(2).asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key + 2)).toList(),
            ),
          ];
        default:
          return [
            Row(
              children: imageUrls.sublist(0, 2).asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key)).toList(),
            ),
            Row(
              children: [
                ...imageUrls.sublist(2, 4).asMap().entries.map((e) => _buildImage(e.value, MediaQuery.of(context).size.width * 0.5, e.key + 2)).toList(),
                if (imageUrls.length > 4)
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(imageUrls[4], double.infinity, 4),
                        Container(
                          color: Colors.black38,
                          child: Center(
                            child: Text(
                              '+${imageUrls.length - 4} more images',
                              style: TextStyle(color: Colors.white, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ];
      }
    }



    return Container(
      height: imageUrls.length > 2 ? imageHeight * 2 : imageHeight, // fixed height
      child: Column(
        children: _buildImages(),
      ),
    );
  }
}

class ImageFullScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialPage;

  ImageFullScreen({required this.imageUrls, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageController: PageController(initialPage: initialPage),
          ),
        ),
      ),
    );
  }
}
