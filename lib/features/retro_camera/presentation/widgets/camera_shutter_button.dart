import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class CameraShutterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCounting;

  const CameraShutterButton({
    super.key,
    required this.onPressed,
    this.isCounting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Take Photo',
      button: true,
      onTap: onPressed,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textPrimary, width: 4),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isCounting
                ? const Icon(AppIcons.hourglass, color: AppColors.accent, size: 40)
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
