import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:xingcam/core/services/harmonization_service.dart';

void main() {
  group('HarmonizationService — Color Transfer', () {
    late File fgFile;
    late File bgFile;

    setUp(() async {
      final tempDir = Directory.systemTemp.path;
      
      // Create a solid RED foreground image
      final fgImg = img.Image(width: 10, height: 10)..clear(img.ColorRgb8(255, 0, 0));
      fgFile = File('$tempDir/fg.jpg')..writeAsBytesSync(img.encodeJpg(fgImg));

      // Create a solid BLUE background image
      final bgImg = img.Image(width: 10, height: 10)..clear(img.ColorRgb8(0, 0, 255));
      bgFile = File('$tempDir/bg.jpg')..writeAsBytesSync(img.encodeJpg(bgImg));
    });

    tearDown(() async {
      if (fgFile.existsSync()) await fgFile.delete();
      if (bgFile.existsSync()) await bgFile.delete();
      final harmonized = File(fgFile.path.replaceAll('.jpg', '_harmonized.jpg'));
      if (harmonized.existsSync()) await harmonized.delete();
    });

    test('harmonize significantly shifts foreground color towards background mean', () async {
      final harmonizedFile = await HarmonizationService.harmonize(
        foregroundPath: fgFile.path,
        backgroundPath: bgFile.path,
      );

      final harmonizedImg = img.decodeImage(harmonizedFile.readAsBytesSync())!;
      final pixel = harmonizedImg.getPixel(0, 0);

      // Original FG was pure RED (255, 0, 0). 
      // BG was pure BLUE (0, 0, 255).
      // Harmonization should significantly decrease Red and increase Blue.
      expect(pixel.r, lessThan(200)); 
      expect(pixel.b, greaterThan(100));
    });

    test('throws exception on invalid image paths', () {
      expect(
        () => HarmonizationService.harmonize(
          foregroundPath: 'invalid_path.jpg',
          backgroundPath: bgFile.path,
        ),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
