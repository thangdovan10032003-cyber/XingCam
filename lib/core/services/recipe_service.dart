import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Domain Models ────────────────────────────────────────────────────────────

/// A single editing step in a recipe (e.g. LUT at 80%, Grain at 0.3).
class EditStep {
  final String toolId;
  final Map<String, dynamic> params;
  final String? label;

  const EditStep({
    required this.toolId,
    required this.params,
    this.label,
  });

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'params': params,
        if (label != null) 'label': label,
      };

  factory EditStep.fromJson(Map<String, dynamic> j) => EditStep(
        toolId: j['toolId'] as String,
        params: Map<String, dynamic>.from(j['params'] as Map),
        label: j['label'] as String?,
      );
}

/// A named sequence of editing steps that can be saved and re-applied.
class EditRecipe {
  final String id;
  final String name;
  final List<EditStep> steps;
  final DateTime createdAt;
  final String? previewImagePath;

  const EditRecipe({
    required this.id,
    required this.name,
    required this.steps,
    required this.createdAt,
    this.previewImagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'steps': steps.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        if (previewImagePath != null) 'previewImagePath': previewImagePath,
      };

  factory EditRecipe.fromJson(Map<String, dynamic> j) => EditRecipe(
        id: j['id'] as String,
        name: j['name'] as String,
        steps: (j['steps'] as List)
            .map((e) => EditStep.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        previewImagePath: j['previewImagePath'] as String?,
      );
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// RecipeService — Sovereign on-device recipe management.
///
/// Stores [EditRecipe] objects as JSON in SharedPreferences.
/// No cloud dependency, all data stays on device.
class RecipeService {
  static const String _prefsKey = 'xingcam_recipes_v2';

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  /// Saves a new or updated recipe. Overwrites if [recipe.id] already exists.
  static Future<void> saveRecipe(EditRecipe recipe) async {
    final all = await loadAll();
    final idx = all.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      all[idx] = recipe;
    } else {
      all.insert(0, recipe); // newest first
    }
    await _persist(all);
  }

  /// Loads all saved recipes, newest first.
  static Future<List<EditRecipe>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EditRecipe.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[RecipeService] Parse error: $e');
      return [];
    }
  }

  /// Deletes a recipe by ID.
  static Future<void> deleteRecipe(String id) async {
    final all = await loadAll();
    all.removeWhere((r) => r.id == id);
    await _persist(all);
  }

  /// Saves the current preview image for a recipe and returns the local path.
  static Future<String?> savePreviewImage(String recipeId, String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final previewDir = Directory('${dir.path}/xingcam_recipe_previews');
      if (!previewDir.existsSync()) previewDir.createSync(recursive: true);
      final dest = File('${previewDir.path}/preview_$recipeId.jpg');
      await File(sourcePath).copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('[RecipeService] Preview save error: $e');
      return null;
    }
  }

  // ── Apply ─────────────────────────────────────────────────────────────────────

  /// Generates a human-readable description of what a recipe does.
  static String describeRecipe(EditRecipe recipe) {
    if (recipe.steps.isEmpty) return 'Trống';
    final tools = recipe.steps.map((s) => s.label ?? s.toolId).join(' → ');
    return tools;
  }

  /// Returns a unique ID for a new recipe.
  static String generateId() =>
      'xc_recipe_${DateTime.now().millisecondsSinceEpoch}';

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static Future<void> _persist(List<EditRecipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(recipes.map((r) => r.toJson()).toList()));
  }
}
