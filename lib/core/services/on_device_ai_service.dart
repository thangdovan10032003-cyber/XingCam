import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:injectable/injectable.dart';

/// Service to handle on-device Machine Learning tasks using Google ML Kit.
/// Ensures 100% offline (Sovereign) operation.
@lazySingleton
class OnDeviceAiService {
  final FaceDetector _faceDetector;
  final SelfieSegmenter _selfieSegmenter;

  OnDeviceAiService()
      : _faceDetector = FaceDetector(options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          enableClassification: true,
          enableTracking: false,
          performanceMode: FaceDetectorMode.accurate,
        )),
        _selfieSegmenter = SelfieSegmenter(
          mode: SegmenterMode.stream, // Use stream for fast processing, or single for accuracy
          enableRawSizeMask: false,
        );

  /// Analyzes an image and returns a list of detected faces.
  /// Throws an exception if image processing fails.
  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      throw Exception('Face detection failed: $e');
    }
  }

  /// Extracts the subject from the background.
  /// Returns a [SegmentationMask] which contains the confidence of each pixel being in the foreground.
  Future<SegmentationMask?> segmentSubject(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final mask = await _selfieSegmenter.processImage(inputImage);
      return mask;
    } catch (e) {
      throw Exception('Selfie segmentation failed: $e');
    }
  }

  /// Cleans up resources. Needs to be called when service is disposed.
  void close() {
    _faceDetector.close();
    _selfieSegmenter.close();
  }
}
