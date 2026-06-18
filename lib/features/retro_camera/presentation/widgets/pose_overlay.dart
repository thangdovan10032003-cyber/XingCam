import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

enum PoseType { none, sitting, standing, cafe, beach }

class PoseOverlay extends StatelessWidget {
  final PoseType type;
  const PoseOverlay({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == PoseType.none) return const SizedBox.shrink();

    return Opacity(
      opacity: 0.3,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: _getPoseWidget(type),
        ),
      ),
    );
  }

  Widget _getPoseWidget(PoseType type) {
    switch (type) {
      case PoseType.sitting:
        return const Icon(AppIcons.pose, color: AppColors.accent, size: 300); // Placeholder for silhouette
      case PoseType.standing:
        return CustomPaint(
          size: const Size(200, 400),
          painter: _PoseSilhouettePainter(),
        );
      case PoseType.cafe:
        return const Icon(AppIcons.coffee, color: AppColors.accent, size: 300);
      case PoseType.beach:
        return const Icon(AppIcons.beach, color: AppColors.accent, size: 300);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PoseSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    // Simplified human outline for "Standing"
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.addOval(Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height * 0.15)); // Head
    path.moveTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.5, size.height * 0.6); // Torso
    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.4); // Left Arm
    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.4); // Right Arm
    path.moveTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.9); // Left Leg
    path.moveTo(size.width * 0.5, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.9); // Right Leg

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
