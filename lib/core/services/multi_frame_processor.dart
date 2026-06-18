import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

/// MultiFrameProcessor: The heart of XingCam's Computational Photography.
/// Handles ZSL frame fusion, HDR merging, and noise reduction.
class MultiFrameProcessor {
  
  /// Merges a sequence of frames into a single high-quality HDR image.
  /// Runs inside a dedicated Isolate for performance.
  static Future<String> mergeFrames(List<String> framePaths) async {
    return compute(_fusionInternal, framePaths);
  }

  static String _fusionInternal(List<String> paths) {
    if (paths.isEmpty) throw Exception('No frames provided for fusion');

    final List<img.Image> frames = [];
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image != null) frames.add(image);
    }

    if (frames.isEmpty) throw Exception('Failed to decode fusion frames');

    final int width = frames.first.width;
    final int height = frames.first.height;
    final merged = img.Image(width: width, height: height);

    // Multi-Frame Pixel Fusion (Simplified HDR + Noise Reduction)
    // We average the pixels while giving weight to the best-exposed frames 
    // for specific luminance ranges.
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double sumR = 0, sumG = 0, sumB = 0;
        double totalWeight = 0;

        for (final frame in frames) {
          final pixel = frame.getPixel(x, y);
          
          // Simplified weight calculation: Avoid over-exposed (255) and under-exposed (0)
          double brightness = (pixel.r + pixel.g + pixel.b) / (3.0 * 255.0);
          double weight = 1.0 - (brightness - 0.5).abs() * 2.0;
          weight = weight.clamp(0.1, 1.0);

          sumR += pixel.r * weight;
          sumG += pixel.g * weight;
          sumB += pixel.b * weight;
          totalWeight += weight;
        }

        merged.setPixelRgb(x, y, 
          (sumR / totalWeight).toInt(), 
          (sumG / totalWeight).toInt(), 
          (sumB / totalWeight).toInt()
        );
      }
    }

    final outPath = paths.first.replaceAll('.jpg', '_hdr_merged.jpg');
    File(outPath).writeAsBytesSync(img.encodeJpg(merged));
    return outPath;
  }
}
