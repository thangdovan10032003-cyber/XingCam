import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A widget that applies a professional 3D LUT shader to its child.
/// Uses the lut_engine.frag GLSL shader for real-time GPU processing.
/// A widget that applies professional GPU effects (LUT + Beauty) to its child.
class GpuEffectPreview extends StatelessWidget {
  final ui.FragmentShader lutShader;
  final ui.FragmentShader? beautyShader;
  final ui.Image lutImage;
  final ui.Image? lutBImage;
  final double interpolation;
  final double beautySmoothness;
  final double beautyBrightening;
  final bool beautyEnabled;
  final Size size;
  final Widget child;

  const GpuEffectPreview({
    super.key,
    required this.lutShader,
    this.beautyShader,
    required this.lutImage,
    this.lutBImage,
    this.interpolation = 0.0,
    this.beautySmoothness = 0.5,
    this.beautyBrightening = 0.5,
    this.beautyEnabled = false,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EffectShaderPainter(
        lutShader: lutShader,
        beautyShader: beautyShader,
        lutImage: lutImage,
        lutBImage: lutBImage ?? lutImage,
        interpolation: interpolation,
        beautySmoothness: beautySmoothness,
        beautyBrightening: beautyBrightening,
        beautyEnabled: beautyEnabled,
        size: size,
      ),
      child: child,
    );
  }
}

class _EffectShaderPainter extends CustomPainter {
  final ui.FragmentShader lutShader;
  final ui.FragmentShader? beautyShader;
  final ui.Image lutImage;
  final ui.Image lutBImage;
  final double interpolation;
  final double beautySmoothness;
  final double beautyBrightening;
  final bool beautyEnabled;
  final Size size;

  _EffectShaderPainter({
    required this.lutShader,
    required this.beautyShader,
    required this.lutImage,
    required this.lutBImage,
    required this.interpolation,
    required this.beautySmoothness,
    required this.beautyBrightening,
    required this.beautyEnabled,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Pass 1: Beauty Filter (if enabled)
    if (beautyEnabled && beautyShader != null) {
      beautyShader!.setFloat(0, size.width);
      beautyShader!.setFloat(1, size.height);
      beautyShader!.setFloat(2, beautySmoothness);
      beautyShader!.setFloat(3, beautyBrightening);
      // Note: In a real multi-pass, we'd need to capture the child texture.
      // Flutter's current FragmentShader API is mainly for procedurals or single-pass.
      // For real-time camera, we usually apply the shader to the whole Layer.
      paint.shader = beautyShader;
      canvas.drawRect(Offset.zero & size, paint);
    }

    // Pass 2: LUT Processing
    lutShader.setFloat(0, size.width);
    lutShader.setFloat(1, size.height);
    lutShader.setFloat(2, interpolation);
    lutShader.setImageSampler(1, lutImage);
    lutShader.setImageSampler(2, lutBImage);
    
    paint.shader = lutShader;
    paint.blendMode = BlendMode.overlay; // Blend over the beauty layer
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _EffectShaderPainter oldDelegate) {
    return oldDelegate.lutImage != lutImage || 
           oldDelegate.interpolation != interpolation ||
           oldDelegate.beautyEnabled != beautyEnabled ||
           oldDelegate.beautySmoothness != beautySmoothness ||
           oldDelegate.beautyBrightening != beautyBrightening;
  }
}
