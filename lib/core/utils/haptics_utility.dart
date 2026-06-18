import 'package:flutter/services.dart';

class HapticsUtility {
  /// Simulates a mechanical shutter release.
  static Future<void> shutter() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Simulates a delicate dial click (e.g. changing filters).
  static Future<void> dialClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Simulates a mechanical lens motor movement (e.g. zooming).
  static Future<void> lensStep() async {
    await HapticFeedback.lightImpact();
  }

  /// Simulates a mechanical lever wind (e.g. state transitions).
  static Future<void> leverWind() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  /// Specialized Light Dial Tick for continuous controllers (sliders/knobs).
  static Future<void> dialTick() async {
    await HapticFeedback.lightImpact();
  }

  // ── Extra aliases used across AI screens ─────────────────────────────────

  /// Light feedback (alias for lightImpact).
  static Future<void> lightFeedback() async {
    await HapticFeedback.lightImpact();
  }

  /// Light single impact.
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium single impact.
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy single impact (peak haptic).
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Very light tick (alias for selectionClick).
  static Future<void> lightTick() async {
    await HapticFeedback.selectionClick();
  }

  /// Premium: Mechanical "Ratchet" or "Dial" feel for sliders.
  static Future<void> mechanicalClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Premium: Subtle pulse during long-running AI operations.
  static Future<void> processingPulse() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 400));
    await HapticFeedback.lightImpact();
  }

  /// Premium: Harmonic success fanfare when a task completes.
  static Future<void> successFanfare() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.selectionClick();
  }
}

/// DialHapticEngine: Logic to trigger haptics based on value increments.
/// Prevents haptic fatigue by limiting frequency of vibrations.
class DialHapticEngine {
  double _lastValue = 0.0;
  final double threshold;

  DialHapticEngine({this.threshold = 0.05});

  /// Call this when a slider/dial value changes.
  /// Triggers a tick if the change exceeds the threshold.
  void onValueChanged(double newValue) {
    if ((newValue - _lastValue).abs() >= threshold) {
      HapticsUtility.dialTick();
      _lastValue = newValue;
    }
  }

  /// Resets the engine state (e.g. when starting a new gesture).
  void reset(double startValue) {
    _lastValue = startValue;
  }
}
