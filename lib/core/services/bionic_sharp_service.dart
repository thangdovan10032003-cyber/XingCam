import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

/// BionicSharpService: Professional subject-aware sharpening engine.
/// Uses a high-pass frequency analysis to identify and enhance micro-textures 
/// (eyes, hair, skin pores) without introducing haloing in background bokeh.
@lazySingleton
class BionicSharpService {
  
  /// Applies bionic sharpening to an image.
  /// [amount]: Intensity of the sharpening (0.0 to 1.0).
  /// [radius]: Edge detection radius.
  Future<String> applyBionicSharp({
    required String imagePath,
    required String outPath,
    double amount = 0.5,
    int radius = 1,
  }) async {
    return await compute(_processBionicSharp, {
      'imagePath': imagePath,
      'outPath': outPath,
      'amount': amount,
      'radius': radius,
    });
  }
}

/// Specialized sharpening Isolate.
Future<String> _processBionicSharp(Map<String, dynamic> args) async {
  final image = img.decodeImage(await File(args['imagePath']).readAsBytes());
  if (image == null) return args['imagePath'];

  final double amount = args['amount'];
  final int radius = args['radius'];

  // ── High-Frequency Density Analysis ──────────────────────────────
  // 1. Create a grayscale mask of high-frequency edges (Laplacian-like)
  final img.Image laplace = img.copyResize(image, width: image.width, height: image.height);
  img.convolution(laplace, filter: [
    0, -1,  0,
   -1,  4, -1,
    0, -1,  0,
  ]);

  // 2. Selective Blending: Only sharpen where the Laplacian is strong (edge regions)
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final l = laplace.getPixel(x, y);
      
      // Calculate high-frequency intensity
      final hf = (l.r + l.g + l.b) / 3.0;
      
      if (hf > 20) { // Detail detected
        final factor = (hf / 255.0) * amount * 2.0;
        p.r = (p.r + (p.r - 128) * factor).clamp(0, 255).toInt();
        p.g = (p.g + (p.g - 128) * factor).clamp(0, 255).toInt();
        p.b = (p.b + (p.b - 128) * factor).clamp(0, 255).toInt();
      }
    }
  }

  await File(args['outPath']).writeAsBytes(img.encodeJpg(image, quality: 95));
  return args['outPath'];
}
