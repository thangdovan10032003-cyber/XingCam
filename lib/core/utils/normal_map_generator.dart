import 'dart:io';
import 'package:image/image.dart' as img;

/// NormalMapGenerator: Estimates surface geometry (Normal Map) from 2D image data.
/// Uses the grayscale gradient to approximate surface vectors (Bump => Normal).
class NormalMapGenerator {
  
  /// Generates a Normal Map (RGB) from a source image.
  /// R: x-normal, G: y-normal, B: z-normal.
  static Future<File> generate({
    required String inputPath,
    double strength = 2.0,
  }) async {
    final bytes = File(inputPath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    // 1. Convert to Grayscale
    final grayscale = img.grayscale(image);
    final width = grayscale.width;
    final height = grayscale.height;

    // 2. Sobel-style Normal Estimation
    final normalMap = img.Image(width: width, height: height);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Sample surrounding pixels (Luminance)
        final double topLeft = _getLuminance(grayscale, x - 1, y - 1);
        final double top = _getLuminance(grayscale, x, y - 1);
        final double topRight = _getLuminance(grayscale, x + 1, y - 1);
        final double left = _getLuminance(grayscale, x - 1, y);
        final double right = _getLuminance(grayscale, x + 1, y);
        final double bottomLeft = _getLuminance(grayscale, x - 1, y + 1);
        final double bottom = _getLuminance(grayscale, x, y + 1);
        final double bottomRight = _getLuminance(grayscale, x + 1, y + 1);

        // Compute Gradients
        final dx = (topRight + 2.0 * right + bottomRight) - (topLeft + 2.0 * left + bottomLeft);
        final dy = (bottomLeft + 2.0 * bottom + bottomRight) - (topLeft + 2.0 * top + topRight);
        final dz = 1.0 / strength;

        // Normalize Vector
        final length = 1.0 / (dx * dx + dy * dy + dz * dz);
        final nx = dx * length;
        final ny = dy * length;
        final nz = dz * length;

        // Map [-1, 1] to [0, 255]
        final r = ((nx + 1.0) * 0.5 * 255).toInt();
        final g = ((ny + 1.0) * 0.5 * 255).toInt();
        final b = ((nz + 1.0) * 0.5 * 255).toInt();

        normalMap.setPixelRgb(x, y, r, g, b);
      }
    }

    final outPath = inputPath.replaceAll('.jpg', '_normal.jpg');
    File(outPath).writeAsBytesSync(img.encodeJpg(normalMap));
    return File(outPath);
  }

  static double _getLuminance(img.Image img, int x, int y) {
    final pixel = img.getPixel(x, y);
    return pixel.luminance / 255.0;
  }
}
