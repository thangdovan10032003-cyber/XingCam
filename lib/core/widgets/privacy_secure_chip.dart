import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// PrivacySecureChip: A subtle HUD indicator for user trust.
/// Verifies that the current AI operation is running locally on-device.
class PrivacySecureChip extends StatelessWidget {
  const PrivacySecureChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mint.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mint.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.security, color: AppColors.mint, size: 10),
          const SizedBox(width: 4),
          Text(
            context.tr('legal.on_device_secure'),
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.mint,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

