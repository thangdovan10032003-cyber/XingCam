import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:xingcam/features/retro_camera/domain/entities/grain_settings.dart';

/// Simulates film grain by painting a noise texture over the camera preview.
/// When [GrainSettings.animated] is true the texture refreshes every frame
/// using a [Ticker] so it looks like genuine film grain.
class GrainOverlay extends StatefulWidget {
  final GrainSettings settings;

  const GrainOverlay({super.key, required this.settings});

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.settings.animated) {
      _ticker = createTicker((_) {
        setState(() => _seed++);
      })..start();
    }
  }

  @override
  void didUpdateWidget(GrainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings.animated && _ticker == null) {
      _ticker = createTicker((_) => setState(() => _seed++))..start();
    } else if (!widget.settings.animated) {
      _ticker?.stop();
      _ticker?.dispose();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(
          intensity: widget.settings.intensity,
          seed: _seed,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double intensity;
  final int seed;

  _GrainPainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw random noise dots
    final count = (size.width * size.height * intensity * 0.06).toInt();
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final alpha = (rng.nextDouble() * 180 + 30).toInt().clamp(0, 255);
      final radius = rng.nextDouble() * 1.5 + 0.5;

      paint.color = Color.fromARGB(alpha, 255, 255, 255);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.intensity != intensity;
}
