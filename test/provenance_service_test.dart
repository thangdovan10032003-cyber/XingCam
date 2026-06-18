import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xingcam/core/services/provenance_service.dart';

void main() {
  group('ProvenanceService — C2PA Signing', () {
    late File testImage;

    setUp(() async {
      // Create a dummy test image
      testImage = File('${Directory.systemTemp.path}/test_image.jpg');
      await testImage.writeAsBytes(List.filled(1024, 0x42)); // 1KB dummy
    });

    tearDown(() async {
      if (testImage.existsSync()) await testImage.delete();
      final manifest = File('${testImage.path}.xc2pa.json');
      if (manifest.existsSync()) await manifest.delete();
    });

    test('signImage creates a sidecar .xc2pa.json manifest', () async {
      final manifestPath = await ProvenanceService.signImage(
        imagePath: testImage.path,
        editHistory: ['lut:fuji', 'grain:0.3'],
      );
      expect(File(manifestPath).existsSync(), isTrue);
    });

    test('manifest contains a valid SHA-256 image hash', () async {
      final manifestPath = await ProvenanceService.signImage(
        imagePath: testImage.path,
        editHistory: [],
      );
      final content = await File(manifestPath).readAsString();
      expect(content, contains('"algorithm": "sha256"'));
      expect(content, contains('"hash"'));
    });

    test('manifest contains AI tool labels from history', () async {
      final manifestPath = await ProvenanceService.signImage(
        imagePath: testImage.path,
        editHistory: ['ai_uncrop', 'face_beautify', 'grain'],
      );
      final content = await File(manifestPath).readAsString();
      // AI tools should be extracted from history
      expect(content, contains('ai_uncrop'));
      expect(content, contains('face_beautify'));
    });

    test('manifest has a non-empty HMAC signature', () async {
      final manifestPath = await ProvenanceService.signImage(
        imagePath: testImage.path,
        editHistory: ['lut:kodak'],
      );
      final content = await File(manifestPath).readAsString();
      expect(content, contains('"algorithm": "HMAC-SHA256"'));
      expect(content, contains('"value"'));
    });
  });
}
