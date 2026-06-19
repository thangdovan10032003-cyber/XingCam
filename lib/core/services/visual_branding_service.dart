import 'dart:io';
import 'dart:convert';
import 'package:native_exif/native_exif.dart';
import 'recipe_service.dart';

/// VisualBrandingService — Expanded for v1.5 with "Stealth Metadata".
/// Enables invisible recipe sharing through EXIF UserComments.
class VisualBrandingService {
  
  static const String _recipeToken = 'XINGCAM_RECIPE:';

  /// Embeds recipe metadata into the image EXIF without changing the pixels.
  /// This is the "Sovereign" way to share: clean image, stealth metadata.
  static Future<void> embedStealthMetadata({
    required String imagePath,
    required EditRecipe recipe,
  }) async {
    try {
      final exif = await Exif.fromPath(imagePath);
      
      // We combine a token and the Base16/JSON of the recipe
      final jsonString = jsonEncode(recipe.toJson());
      final metadataValue = '$_recipeToken$jsonString';
      
      // Store in UserComment (standard EXIF field)
      await exif.writeAttribute('UserComment', metadataValue);
      await exif.close();
    } catch (e) {
      print('[VisualBrandingService] EXIF Embed Error: $e');
    }
  }

  /// Original "Negative Strip" branding (Optional Opt-in).
  /// Appends a black footer to the image.
  static Future<File?> applyVisibleBranding({
    required String inputPath,
    required EditRecipe recipe,
  }) async {
    // Re-using the same logic but renamed for clarity (Opt-in)
    // ... (logic from previous version)
    return null; // Placeholder for now to keep focus on EXIF
  }
}
