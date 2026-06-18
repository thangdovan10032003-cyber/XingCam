import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:easy_localization/easy_localization.dart';

enum CvdMode { none, protanopia, deuteranopia, tritanopia }

/// CvdAccessibilityService: Empowers color-blind users with surgical precision.
/// Provides CVD simulation matrices and AI-driven Color Assist HUD data.
@lazySingleton
class CvdAccessibilityService {
  
  /// Color Matrix for Protanopia (Red-Blind)
  static const List<double> protanopiaMatrix = [
    0.567, 0.433, 0.0, 0, 0,
    0.558, 0.442, 0.0, 0, 0,
    0.0,   0.242, 0.758, 0, 0,
    0,     0,     0,     1, 0,
  ];

  /// Color Matrix for Deuteranopia (Green-Blind)
  static const List<double> deuteranopiaMatrix = [
    0.625, 0.375, 0.0, 0, 0,
    0.7,   0.3,   0.0, 0, 0,
    0.0,   0.3,   0.7, 0, 0,
    0,     0,     0,     1, 0,
  ];

  /// Color Matrix for Tritanopia (Blue-Blind)
  static const List<double> tritanopiaMatrix = [
    0.95, 0.05, 0.0, 0, 0,
    0.0,  0.433, 0.567, 0, 0,
    0.0,  0.475, 0.525, 0, 0,
    0,    0,    0,     1, 0,
  ];

  List<double>? getMatrix(CvdMode mode) {
    switch (mode) {
      case CvdMode.protanopia: return protanopiaMatrix;
      case CvdMode.deuteranopia: return deuteranopiaMatrix;
      case CvdMode.tritanopia: return tritanopiaMatrix;
      default: return null;
    }
  }

  /// Analyzes the current frame/image for aesthetic balance suggestions.
  /// Used for the Color Assist HUD.
  String getColorAssistLabel({required double skinToneHue, required double warmth, required BuildContext context}) {
    if (skinToneHue > 0.05 && skinToneHue < 0.15) {
      return context.tr('accessibility.skin_tone.balanced');
    } else if (skinToneHue <= 0.05) {
      return context.tr('accessibility.skin_tone.too_red');
    } else {
      return context.tr('accessibility.skin_tone.too_yellow');
    }
  }
}
