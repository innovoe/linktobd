import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
Future<XFile> compressImage(XFile largeImage, int quality) async {
  final dir = await getTemporaryDirectory(); // Get temp directory
  final targetPath = "${dir.path}/compressed_${largeImage.name}";

  XFile? result = await FlutterImageCompress.compressAndGetFile(
    largeImage.path, // Input file
    targetPath,      // Output file
    quality: quality,     // Compression quality
  );

  return result ?? largeImage; // Return compressed file or original if compression failed
}
