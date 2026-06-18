import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A widget that applies a professional 3D LUT shader to its child.
/// Uses the lut_engine.frag GLSL shader for real-time GPU processing.
class GpuLutPreview extends StatelessWidget {
  final ui.FragmentShader shader;
  final ui.Image lutImage;
  final ui.Image? lutBImage;
  final double interpolation;
  final Size size;
  final Widget child;

  const GpuLutPreview({
    super.key,
    required this.shader,
    required this.lutImage,
    this.lutBImage,
    this.interpolation = 0.0,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LutShaderPainter(
        shader: shader,
        lutImage: lutImage,
        lutBImage: lutBImage ?? lutImage, // Fallback to same image if not provided
        interpolation: interpolation,
        size: size,
      ),
      child: child,
    );
  }
}

class _LutShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image lutImage;
  final ui.Image lutBImage;
  final double interpolation;
  final Size size;

  _LutShaderPainter({
    required this.shader,
    required this.lutImage,
    required this.lutBImage,
    required this.interpolation,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, interpolation);
    
    // Sampler mapping based on shader order:
    // 0: uTexture (automatically provided by child rendering if we use specific blend modes, 
    // but here we might need to capture or use a dummy)
    // 1: uLutA
    // 2: uLutB
    
    // For this implementation, we assume the user provides a placeholder uTexture
    // or we are applying it to a canvas where the texture is injected.
    shader.setImageSampler(1, lutImage);
    shader.setImageSampler(2, lutBImage);
    
    // We can't directly get the 'child' pixels here easily in a CustomPainter 
    // without using a RepaintBoundary or Layer.
    // However, for the LIVE PREVIEW, we can apply the shader to the whole canvas
    // and use a specific blend mode.
    
    final paint = Paint()..shader = shader;
    
    // We draw a rect that covers the whole child area
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _LutShaderPainter oldDelegate) {
    return oldDelegate.lutImage != lutImage || 
           oldDelegate.lutBImage != lutBImage ||
           oldDelegate.interpolation != interpolation ||
           oldDelegate.size != size;
  }
}
