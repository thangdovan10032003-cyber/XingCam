import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/services/biometric_consent_service.dart';

/// BiometricConsentModal: A premium glassmorphic dialog for legal compliance.
/// Explains the "On-Device-Only" nature of XingCam's facial processing.
class BiometricConsentModal extends StatelessWidget {
  const BiometricConsentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.privacy, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                context.tr('legal.consent.title'),
                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('legal.consent.desc'),
            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.tr('common.cancel'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    await BiometricConsentService.acceptConsent();
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  child: Text(context.tr('legal.consent.agree'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              context.tr('legal.consent.compliance'),
              style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.24), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> show(BuildContext context) async {
    if (await BiometricConsentService.hasConsented()) return true;
    
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => const BiometricConsentModal(),
    ) ?? false;
  }
}
