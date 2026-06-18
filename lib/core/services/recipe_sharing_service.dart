import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// FilmRecipeSharingService: Sovereign Sharing Hub for XingCam Recipes.
/// 
/// Allows users to generate on-device shortcodes for their custom LUT + Grain + LightLeak combinations.
class FilmRecipeSharingService {
  
  /// Generates a high-density, fixed-width Base16 shortcode for QR stability.
  /// Format: [LUT(2)][GRAIN(2)][SEED(4)] = Exactly 8 hex chars.
  static String generateShortcode({
    required double lutIntensity,
    required double grainAmount,
    required int lightLeakSeed,
  }) {
    // Requirement 1: Clamp values to [0.0, 2.55] to guarantee 2-digit hex (00-FF)
    final lutVal = (lutIntensity.clamp(0.0, 2.55) * 100).toInt();
    final grainVal = (grainAmount.clamp(0.0, 2.55) * 100).toInt();
    
    // Requirement 2: Force positive seed and bound to 4-digit hex (0000-FFFF)
    final seedVal = lightLeakSeed.abs() % 0xFFFF;
    
    final payload = '${lutVal.toRadixString(16).padLeft(2, '0')}'
                    '${grainVal.toRadixString(16).padLeft(2, '0')}'
                    '${seedVal.toRadixString(16).padLeft(4, '0')}';
    
    return 'XC-$payload'.toUpperCase();
  }

  /// Decodes a high-density payload with strict width validation.
  static Map<String, dynamic>? decodeShortcode(String code) {
    if (!code.startsWith('XC-')) return null;
    try {
      final payload = code.substring(3);
      
      // Requirement 3: Safety check - exactly 8 characters to prevent index shift crashes
      if (payload.length != 8) return null;

      final lut = int.parse(payload.substring(0, 2), radix: 16) / 100.0;
      final grain = int.parse(payload.substring(2, 4), radix: 16) / 100.0;
      final seed = int.parse(payload.substring(4, 8), radix: 16);
      
      return {
        'lutIntensity': lut,
        'grainAmount': grain,
        'lightLeakSeed': seed,
      };
    } catch (e) {
      return null;
    }
  }

  /// Displays a professional Sharing Sheet with QR Code simulation.
  static void showShareSheet(BuildContext context, String shortcode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('recipe.share_title'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Mock QR Code
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(AppIcons.qrCode, size: 120, color: AppColors.background),
            ),
            
            const SizedBox(height: 24),
            Text(context.tr('recipe.shortcode_label', args: [shortcode]), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(context.tr('recipe.share_desc'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12)),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary.withOpacity(0.1),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

