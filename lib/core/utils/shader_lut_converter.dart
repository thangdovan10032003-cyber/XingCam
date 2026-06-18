import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:xingcam/core/utils/lut_parser.dart';

class ShaderLutConverter {
  /// Converts a [Lut3D] object into a 2D Atlas Texture [ui.Image].
  /// Supports both 32 (1024x32) and 64 (512x512 grid) LUT sizes.
  static Future<ui.Image> createLutImage(Lut3D lut) async {
    final size = lut.size;
    final int width;
    final int height;

    if (size == 64) {
      width = 512;
      height = 512;
    } else {
      width = size * size;
      height = size;
    }
    
    final rgbaData = Uint8List(width * height * 4);
    
    for (int b = 0; b < size; b++) {
      for (int g = 0; g < size; g++) {
        for (int r = 0; r < size; r++) {
          final result = lut.lookup(r / (size - 1), g / (size - 1), b / (size - 1));
          
          int destX, destY;
          if (size == 64) {
            // 8x8 grid of 64x64 squares
            final gridX = b % 8;
            final gridY = b ~/ 8;
            destX = gridX * 64 + r;
            destY = gridY * 64 + g;
          } else {
            // Horizontal atlas (size*size x size)
            destX = (b * size) + r;
            destY = g;
          }
          
          final pos = (destY * width + destX) * 4;
          rgbaData[pos] = (result[0] * 255).clamp(0, 255).toInt();
          rgbaData[pos + 1] = (result[1] * 255).clamp(0, 255).toInt();
          rgbaData[pos + 2] = (result[2] * 255).clamp(0, 255).toInt();
          rgbaData[pos + 3] = 255;
        }
      }
    }
    
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbaData,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    
    return completer.future;
  }
}
