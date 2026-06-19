import 'dart:convert';
import 'dart:io';
import 'package:native_exif/native_exif.dart';
import 'package:xingcam/core/services/recipe_service.dart';

/// FilmRecipeSharingService — v1.5 Core EXIF Engine.
/// Handles embedding recipe metadata into JPEG files for "Stealth Viral" growth.
class FilmRecipeSharingService {
  static const String _recipeToken = 'XINGCAM_RECIPE:';

  /// Embeds a recipe into a JPEG image's UserComment field.
  static Future<void> embedRecipeInPhoto(String imagePath, EditRecipe recipe) async {
    final exif = await Exif.fromPath(imagePath);
    try {
      final recipeJson = jsonEncode(recipe.toJson());
      final metadataString = '$_recipeToken$recipeJson';
      
      await exif.writeAttribute('UserComment', metadataString);
    } finally {
      await exif.close();
    }
  }
}

/// RecipeSnatcherService — Extracts and parses recipe metadata from shared photos.
class RecipeSnatcherService {
  static const String _recipeToken = 'XINGCAM_RECIPE:';

  /// Extracts recipe from photo metadata.
  static Future<EditRecipe?> extractRecipeFromPhoto(String imagePath) async {
    if (!File(imagePath).existsSync()) return null;

    final exif = await Exif.fromPath(imagePath);
    try {
      final userComment = await exif.getAttribute('UserComment');
      
      if (userComment != null && userComment.toString().startsWith(_recipeToken)) {
        final jsonString = userComment.toString().substring(_recipeToken.length);
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return EditRecipe.fromJson(data);
      }
    } catch (e) {
      print('RecipeSnatcher error: $e');
    } finally {
      await exif.close();
    }
    return null;
  }
}
