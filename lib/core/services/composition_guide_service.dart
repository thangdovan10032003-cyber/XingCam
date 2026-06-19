/// CompositionGuideService: AI-driven directorial assistance for cinematic photography.
/// Detects salient objects and provides real-time guidance based on professional composition rules.
class CompositionGuideService {
  
  /// Analyzes the current frame for composition quality.
  /// Returns guidance text and alignment metadata.
  static Map<String, dynamic> analyzeComposition({
    required double subjectX, // 0.0 to 1.0 (Simulated from saliency detection)
    required double subjectY,
    required double deviceTilt, // -1.0 to 1.0
  }) {
    String guidance = '';
    bool isAligned = false;

    // RULE 1: Golden Ratio (Vertical)
    const double goldenLeft = 0.382;
    const double goldenRight = 0.618;
    
    if ((subjectX - goldenLeft).abs() < 0.05 || (subjectX - goldenRight).abs() < 0.05) {
      isAligned = true;
    } else if (subjectX < goldenLeft) {
      guidance = 'Shift slightly RIGHT';
    } else if (subjectX > goldenRight) {
      guidance = 'Shift slightly LEFT';
    }

    // RULE 2: Horizon/Tilt Leveling
    if (deviceTilt.abs() > 0.05) {
      guidance += '${guidance.isEmpty ? '' : ' & '}Level the HORIZON';
      isAligned = false;
    }

    if (guidance.isEmpty && isAligned) {
      guidance = 'PERFECT COMPOSITION';
    }

    return {
      'guidance': guidance,
      'isAligned': isAligned,
      'lines': [goldenLeft, goldenRight], // Normalized X positions for guide lines
    };
  }
}
