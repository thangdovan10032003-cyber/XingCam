import 'package:flutter/services.dart';

/// HapticEngine: Provides mechanical-grade tactile feedback across XingCam.
/// Essential for making digital creative controls feel like physical hardware.
class HapticEngine {
  
  /// Provides a light tactile 'tick' for slider increments or dial movements.
  static Future<void> lightTick() async {
    await HapticFeedback.lightImpact();
  }

  /// Provides a medium tactile feedback for tool selection or mode switches.
  static Future<void> mediumTick() async {
    await HapticFeedback.mediumImpact();
  }

  /// Provides a heavy vibration for errors or destructive actions.
  static Future<void> heavyTick() async {
    await HapticFeedback.vibrate();
  }

  /// Custom pattern for AI completion success.
  static Future<void> successPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }
}
