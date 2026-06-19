import 'dart:typed_data';
import 'package:image/image.dart' as img;

class Lut3D {
  final int size;
  final Float32List data;

  Lut3D(this.size, this.data);

  factory Lut3D.fromCubeFile(String content) {
    int size = 0;
    List<double> values = [];

    final lines = content.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('LUT_3D_SIZE')) {
        size = int.parse(line.split(' ').last);
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length == 3) {
          values.add(double.parse(parts[0]));
          values.add(double.parse(parts[1]));
          values.add(double.parse(parts[2]));
        }
      }
    }

    return Lut3D(size, Float32List.fromList(values));
  }

  // Linear interpolation for a color
  List<double> lookup(double r, double g, double b) {
    // scale to [0, size - 1]
    final rf = r * (size - 1);
    final gf = g * (size - 1);
    final bf = b * (size - 1);

    final r0 = rf.floor();
    final g0 = gf.floor();
    final b0 = bf.floor();

    final r1 = (r0 + 1).clamp(0, size - 1);
    final g1 = (g0 + 1).clamp(0, size - 1);
    final b1 = (b0 + 1).clamp(0, size - 1);

    final dr = rf - r0;
    final dg = gf - g0;
    final db = bf - b0;

    // Trilinear interpolation logic (simplified for speed or full accurate)
    // For now, let's do accurate trilinear lookup
    
    double getAt(int ir, int ig, int ib, int channel) {
      final index = (ib * size * size + ig * size + ir) * 3 + channel;
      return data[index];
    }

    double lerp(int channel) {
      final c000 = getAt(r0, g0, b0, channel);
      final c100 = getAt(r1, g0, b0, channel);
      final c010 = getAt(r0, g1, b0, channel);
      final c110 = getAt(r1, g1, b0, channel);
      final c001 = getAt(r0, g0, b1, channel);
      final c101 = getAt(r1, g0, b1, channel);
      final c011 = getAt(r0, g1, b1, channel);
      final c111 = getAt(r1, g1, b1, channel);

      final c00 = c000 * (1 - dr) + c100 * dr;
      final c10 = c010 * (1 - dr) + c110 * dr;
      final c01 = c001 * (1 - dr) + c101 * dr;
      final c11 = c011 * (1 - dr) + c111 * dr;

      final c0 = c00 * (1 - dg) + c10 * dg;
      final c1 = c01 * (1 - dg) + c11 * dg;

      return c0 * (1 - db) + c1 * db;
    }

    return [lerp(0), lerp(1), lerp(2)];
  }

  /// Apply this LUT to an image.Image using trilinear interpolation.
  void applyToImage(img.Image image) {
    for (var pixel in image) {
      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      final result = lookup(r, g, b);
      pixel.r = (result[0] * 255).clamp(0, 255).toInt();
      pixel.g = (result[1] * 255).clamp(0, 255).toInt();
      pixel.b = (result[2] * 255).clamp(0, 255).toInt();
    }
  }
}
