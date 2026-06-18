import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:xingcam/core/theme/design_tokens.dart';

enum GoboType { palm, blinds, mesh, door, blind, grid, leaves }

class GoboPainter extends CustomPainter {
  final GoboType type;
  final double intensity;
  final double rotation;
  final double scale;

  GoboPainter({
    required this.type,
    required this.intensity,
    required this.rotation,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background.withOpacity(intensity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.scale(scale);
    canvas.translate(-size.width / 2, -size.height / 2);

    switch (type) {
      case GoboType.palm:
        _drawPalm(canvas, size, paint);
        break;
      case GoboType.blinds:
      case GoboType.blind:
        _drawBlinds(canvas, size, paint);
        break;
      case GoboType.mesh:
      case GoboType.grid:
        _drawMesh(canvas, size, paint);
        break;
      case GoboType.door:
        _drawDoor(canvas, size, paint);
        break;
      case GoboType.leaves:
        _drawPalm(canvas, size, paint);
        break;
    }

    canvas.restore();
  }

  void _drawPalm(Canvas canvas, Size size, Paint paint) {
    // Draw simplified palm leaf silhouette
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * math.pi / 180;
      path.moveTo(centerX, centerY);
      path.quadraticBezierTo(
        centerX + math.cos(angle) * 300,
        centerY + math.sin(angle) * 300,
        centerX + math.cos(angle + 0.1) * 400,
        centerY + math.sin(angle + 0.1) * 400,
      );
      path.lineTo(centerX + math.cos(angle - 0.1) * 400, centerY + math.sin(angle - 0.1) * 400);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  void _drawBlinds(Canvas canvas, Size size, Paint paint) {
    for (double i = 0; i < size.height * 2; i += 60) {
      canvas.drawRect(Rect.fromLTWH(-size.width, i - size.height, size.width * 3, 30), paint);
    }
  }

  void _drawMesh(Canvas canvas, Size size, Paint paint) {
    for (double i = 0; i < size.width * 2; i += 40) {
      canvas.drawRect(Rect.fromLTWH(i - size.width, -size.height, 5, size.height * 3), paint);
    }
    for (double i = 0; i < size.height * 2; i += 40) {
      canvas.drawRect(Rect.fromLTWH(-size.width, i - size.height, size.width * 3, 5), paint);
    }
  }

  void _drawDoor(Canvas canvas, Size size, Paint paint) {
     final rect = Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width * 0.4, height: size.height * 0.8);
     canvas.drawRect(Rect.fromLTWH(-size.width, -size.height, size.width * 3, size.height * 3), paint);
     canvas.drawRect(rect, Paint()..color = AppColors.transparent..blendMode = BlendMode.clear);
  }

  @override
  bool shouldRepaint(covariant GoboPainter oldDelegate) => 
    oldDelegate.type != type || oldDelegate.intensity != intensity || 
    oldDelegate.rotation != rotation || oldDelegate.scale != scale;
}
