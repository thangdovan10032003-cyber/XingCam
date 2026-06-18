import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class CameraPoseOverlay extends StatelessWidget {
  final String selectedPose;

  const CameraPoseOverlay({super.key, required this.selectedPose});

  @override
  Widget build(BuildContext context) {
    if (selectedPose == 'None') return const SizedBox.shrink();

    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: 0.3,
          child: _getPoseIcon(),
        ),
      ),
    );
  }

  Widget _getPoseIcon() {
    switch (selectedPose) {
      case 'Full Body':
        return const Icon(AppIcons.pose, color: AppColors.accent, size: 380);
      case 'Portrait':
        return const Icon(AppIcons.beautify, color: AppColors.accent, size: 380);
      case 'Lifestyle':
        return const Icon(AppIcons.coffee, color: AppColors.accent, size: 300);
      default:
        return const SizedBox.shrink();
    }
  }
}
