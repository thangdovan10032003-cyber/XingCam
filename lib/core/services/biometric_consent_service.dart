import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// BiometricConsentService: Manages the legal sovereign gateway for biometric data.
/// Tracks user consent for facial processing to comply with GDPR, BIPA, and Decree 13.
class BiometricConsentService {
  static const String _consentKey = 'xingcam_biometric_consent_v1';
  static const String _consentDateKey = 'xingcam_biometric_consent_date';

  /// Returns true if the user has already consented to biometric processing.
  static Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Displays the consent dialog if not already consented. Returns true if consent is granted.
  static Future<bool> ensureConsent(BuildContext context) async {
    if (await hasConsented()) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force them to choose
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(ctx.tr('legal.consent.title'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ctx.tr('legal.consent.desc'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 16),
            Text(ctx.tr('legal.consent.compliance'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.mint, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('common.cancel'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.tr('legal.consent.agree'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
          ),
        ],
      ),
    );

    if (result == true) {
      await acceptConsent();
      return true;
    }
    return false;
  }

  /// Records the user's consent with a timestamp for legal auditing.
  static Future<void> acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    await prefs.setString(_consentDateKey, DateTime.now().toIso8601String());
  }

  /// Revokes consent (e.g., if user wants to delete biometric data traces).
  static Future<void> revokeConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_consentDateKey);
  }
}
