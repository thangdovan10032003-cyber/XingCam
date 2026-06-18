import 'dart:io';
import 'package:image/image.dart' as img;

/// HarmonizationService: Neural-aesthetic synchronization for compositing.
/// Ensures that a subject composited onto a new background looks natural 
/// by matching color temperature, contrast, and luminosity.
class HarmonizationService {
  
  /// Harmonizes the 'foreground' subject with the 'background' environment.
  /// Returns a path to the harmonized foreground image.
  static Future<File> harmonize({
    required String foregroundPath,
    required String backgroundPath,
  }) async {
    final fgBytes = File(foregroundPath).readAsBytesSync();
    final bgBytes = File(backgroundPath).readAsBytesSync();
    
    final fgImg = img.decodeImage(fgBytes);
    final bgImg = img.decodeImage(bgBytes);
    
    if (fgImg == null || bgImg == null) throw Exception('Failed to decode images');

    // 1. Analyze Background Statistics (Lab color space approximation)
    final bgStats = _getImageStats(bgImg);
    final fgStats = _getImageStats(fgImg);

    // 2. Perform Color Transfer (Reinhard et al.)
    // We adjust FG pixels to match the mean and standard deviation of BG
    final harmonized = img.Image(width: fgImg.width, height: fgImg.height);
    
    for (int y = 0; y < fgImg.height; y++) {
      for (int x = 0; x < fgImg.width; x++) {
        final pixel = fgImg.getPixel(x, y);
        
        // Simplified Channel Matching (RGB approximation of Lab transfer)
        double r = (pixel.r - fgStats.meanR) * (bgStats.stdR / fgStats.stdR) + bgStats.meanR;
        double g = (pixel.g - fgStats.meanG) * (bgStats.stdG / fgStats.stdG) + bgStats.meanG;
        double b = (pixel.b - fgStats.meanB) * (bgStats.stdB / fgStats.stdB) + bgStats.meanB;

        harmonized.setPixelRgb(x, y, 
          r.clamp(0, 255).toInt(), 
          g.clamp(0, 255).toInt(), 
          b.clamp(0, 255).toInt()
        );
      }
    }

    final outPath = foregroundPath.replaceAll('.jpg', '_harmonized.jpg');
    File(outPath).writeAsBytesSync(img.encodeJpg(harmonized));
    return File(outPath);
  }

  static _ImageStats _getImageStats(img.Image image) {
    double sumR = 0, sumG = 0, sumB = 0;
    int count = image.width * image.height;

    for (var pixel in image) {
      sumR += pixel.r;
      sumG += pixel.g;
      sumB += pixel.b;
    }

    double meanR = sumR / count;
    double meanG = sumG / count;
    double meanB = sumB / count;

    double sqDiffR = 0, sqDiffG = 0, sqDiffB = 0;
    for (var pixel in image) {
      sqDiffR += (pixel.r - meanR) * (pixel.r - meanR);
      sqDiffG += (pixel.g - meanG) * (pixel.g - meanG);
      sqDiffB += (pixel.b - meanB) * (pixel.b - meanB);
    }

    return _ImageStats(
      meanR: meanR, meanG: meanG, meanB: meanB,
      stdR: (sqDiffR / count).clamp(0.1, double.infinity), // Avoid div by zero
      stdG: (sqDiffG / count).clamp(0.1, double.infinity),
      stdB: (sqDiffB / count).clamp(0.1, double.infinity),
    );
  }
}

class _ImageStats {
  final double meanR, meanG, meanB;
  final double stdR, stdG, stdB;
  _ImageStats({
    required this.meanR, required this.meanG, required this.meanB,
    required this.stdR, required this.stdG, required this.stdB,
  });
}
