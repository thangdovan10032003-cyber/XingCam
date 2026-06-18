/// KineticCaptionService: Sovereign offline STT stub.
/// Full STT is reserved for a future native plugin; for now this service
/// provides a typed API surface so all call-sites compile correctly.
class KineticCaptionService {
  static bool _isInitialized = false;

  /// Initializes the caption engine.
  static Future<bool> initialize() async {
    _isInitialized = true;
    return _isInitialized;
  }

  /// Generates captions via offline processing.
  /// Currently returns an empty list; extend with native STT plugin later.
  static Future<List<KineticCaptionSegment>> generateCaptions({
    required void Function(String liveWord) onWordDetected,
    String localeId = 'vi_VN',
  }) async {
    if (!_isInitialized) await initialize();
    return [];
  }

  /// Stops listening.
  static Future<void> stopListening() async {}

  /// Returns whether the device supports STT.
  static bool get isAvailable => _isInitialized;

  /// Synthesizes a single word at a specific time.
  static KineticCaptionSegment synthesizeOne(String text, {int delayMs = 0}) {
    return KineticCaptionSegment(
      text: text,
      startMs: delayMs,
      endMs: delayMs + 500,
      scale: 1.5,
      color: '0xFFD4AF37',
    );
  }
}

class KineticCaptionSegment {
  final String text;
  final int startMs;
  final int endMs;
  final double scale;
  final String color;

  KineticCaptionSegment({
    required this.text,
    required this.startMs,
    required this.endMs,
    this.scale = 1.0,
    this.color = '0xFFFFFFFF',
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'startMs': startMs,
    'endMs': endMs,
    'scale': scale,
    'color': color,
  };
}

