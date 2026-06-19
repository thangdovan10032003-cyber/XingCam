import 'dart:math' as math;
import 'package:flutter/material.dart';

/// KineticCaptionPainter: Renders text with physics-based distortions.
/// Features Chromatic Aberration and Jitter for a cinematic feel.
class KineticCaptionPainter extends CustomPainter {
  final String text;
  final double progress; // 0.0 to 1.0
  final Color color;
  final double scale;

  KineticCaptionPainter({
    required this.text,
    required this.progress,
    required this.color,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final double elastic = _easeOutElastic(progress);
    final double opacity = progress.clamp(0.0, 1.0);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'VT323',
          fontSize: 48 * scale * elastic,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: color.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // ── Chromatic Aberration Simulation ──────────────────────────────
    if (progress > 0.8) {
      final double shift = (1.0 - progress) * 10;
      
      // Red Channel
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'VT323',
          fontSize: 48 * scale * elastic,
          color: Colors.red.withValues(alpha: opacity * 0.3),
        ),
      );
      textPainter.layout();
      canvas.drawCircle(offset + Offset(shift, 0), 0, Paint()); // Trigger layer if needed
      textPainter.paint(canvas, offset + Offset(shift, 0));

      // Blue Channel
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'VT323',
          fontSize: 48 * scale * elastic,
          color: Colors.blue.withValues(alpha: opacity * 0.3),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset + Offset(-shift, 0));
    }

    // ── Main Text Layer ───────────────────────────────────────────────
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'VT323',
        fontSize: 48 * scale * elastic,
        color: color.withValues(alpha: opacity),
        shadows: [
           Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(2, 2)),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  double _easeOutElastic(double t) {
    const p = 0.3;
    return math.pow(2, -10 * t) * math.sin((t - p / 4) * (2 * math.pi) / p) + 1;
  }

  @override
  bool shouldRepaint(covariant KineticCaptionPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.text != text;
}
