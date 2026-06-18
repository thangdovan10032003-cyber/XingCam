import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:injectable/injectable.dart';

enum ShutterType {
  leicaM,      // Velvet mechanical click
  hasselblad,  // Authoritative mirror slap
  retroPoint,  // Sharp electronic snick
}

/// ShutterHapticsService: Synthesizes complex vibration patterns to 
/// recreate the "physical soul" of historic camera hardware.
@lazySingleton
class ShutterHapticsService {
  
  /// Triggers a specialized haptic sequence for the selected camera.
  Future<void> trigger(ShutterType type) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) {
      HapticFeedback.heavyImpact();
      return;
    }

    switch (type) {
      case ShutterType.leicaM:
        // Soft, dual-pulse sequence (shutter curtains moving)
        await Vibration.vibrate(
          pattern: [0, 10, 30, 20],
          intensities: [0, 80, 0, 40],
        );
        break;
      case ShutterType.hasselblad:
        // Heavy mirror slap followed by a secondary mechanical echo
        await Vibration.vibrate(
          pattern: [0, 50, 40, 15, 60, 5],
          intensities: [0, 255, 0, 100, 0, 30],
        );
        break;
      case ShutterType.retroPoint:
        // Sharp, instantaneous burst
        await Vibration.vibrate(duration: 15, amplitude: 255);
        break;
    }
  }
}
