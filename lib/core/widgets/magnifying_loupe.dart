import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// MagnifyingLoupe: A precision UI component that displays a magnified
/// circular view of the area under the user's touch.
/// 
/// Essential for selective masking, object removal, and retouching
/// where finger occlusion would otherwise block the user's view.
class MagnifyingLoupe extends StatelessWidget {
  final Offset position;
  final Widget? backgroundImage;
  final double size;
  final double magnification;
  final bool visible;

  const MagnifyingLoupe({
    super.key,
    required this.position,
    this.backgroundImage,
    this.size = 120.0,
    this.magnification = 2.0,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    // Position the loupe at the top of the screen (or offset from finger)
    // to avoid occlusion. Default: Fixed top-right or top-center.
    return Positioned(
      top: 100,
      left: (MediaQuery.of(context).size.width - size) / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.background.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Use a BackropFilter or a transformed child to simulate magnification
              Transform.scale(
                scale: magnification,
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: Offset(
                    -position.dx + (size / (2 * magnification)),
                    -position.dy + (size / (2 * magnification)),
                  ),
                  child: backgroundImage ?? const SizedBox.shrink(),
                ),
              ),
              // Crosshair indicator
              Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A mixin to provide vertical brush offset logic (prevent occlusion).
mixin BrushOffsetMixin {
  /// Calculates the actual brush target position given a touch position.
  /// Standard offset is ~20-30 pixels vertical.
  Offset getBrushPosition(Offset touchPosition, {double offset = -25.0}) {
    return Offset(touchPosition.dx, touchPosition.dy + offset);
  }
}
