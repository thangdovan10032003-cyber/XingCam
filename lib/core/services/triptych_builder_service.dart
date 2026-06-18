import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// TriptychBuilderService — v1.5 Storytelling Engine.
/// Stitches 3 images vertically (9:16) for social media storytelling (Tam cung cách).
class TriptychBuilderService {
  
  /// Stitches 3 images into a single vertical high-res strip (1080x1920 optimized).
  static Future<String?> generateTriptych(List<String> imagePaths) async {
    if (imagePaths.length != 3) return null;

    try {
      final List<img.Image> loadedImages = [];
      for (final path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) loadedImages.add(image);
      }

      if (loadedImages.length != 3) return null;

      // Target sizing: 1080 width, each segment 640 height (Total 1920)
      const targetWidth = 1080;
      const segmentHeight = 640;
      final outImage = img.Image(width: targetWidth, height: targetWidth * 16 ~/ 9); // Total vertical space

      for (int i = 0; i < 3; i++) {
        // Resize segment
        final resized = img.copyResize(
          loadedImages[i], 
          width: targetWidth, 
          height: segmentHeight, 
          interpolation: img.Interpolation.cubic,
        );
        
        // Stitch into combined image
        img.compositeImage(
          outImage, 
          resized, 
          dstY: i * segmentHeight,
        );
      }

      // Save to temp
      final tempDir = await getTemporaryDirectory();
      final outPath = '${tempDir.path}/triptych_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(img.encodeJpg(outImage, quality: 90));

      return outPath;
    } catch (e) {
      print('Triptych Error: $e');
      return null;
    }
  }
}
