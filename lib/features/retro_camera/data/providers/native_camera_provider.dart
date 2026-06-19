import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Connects natively to iOS AVFoundation or Android CameraX via platform channels.
/// Required because the standard `camera` plugin does not support outputting `INPUT_FORMAT_RAW_SENSOR` (DNG).
@lazySingleton
class NativeCameraProvider {
  static const MethodChannel _channel = MethodChannel('com.example.xingcam/camera_pro');

  /// Invokes the native OS driver to capture an uncompressed RAW buffer
  Future<String?> captureRawDng() async {
    try {
      // The path returned corresponds to exactly where macOS/Android saved the DNG
      final String? rawPath = await _channel.invokeMethod('captureRaw');
      return rawPath;
    } on PlatformException {
      print("Deep Tech: Failed to capture RAW: '\${e.message}'.");
      return null;
    }
  }
  
  /// Writes native logic directly into the sensor HAL
  Future<void> setManualExposure(int iso, double shutterSpeed) async {
    try {
      await _channel.invokeMethod('setManualExposure', {
        'iso': iso,
        'shutter_speed': shutterSpeed
      });
    } catch (e) {
      print('Deep Tech: Failed to set exposure bounds: \$e');
    }
  }
}
