import 'recipe_service.dart';

/// HumanSkinFilter — v1.6 Authenticity Engine.
/// Specialized preset that avoids skin smoothing "AI Slop" and preserves texture.
class HumanSkinFilter {
  
  static EditRecipe get recipe => EditRecipe(
    id: 'recipe_human_skin_01',
    name: 'NATURAL HUMAN SKIN',
    createdAt: DateTime.now(),
    steps: [
      const EditStep(
        toolId: 'tone_curve',
        params: {'contrast': 0.05, 'midtones': 1.1},
        label: 'Enhance Depth',
      ),
      const EditStep(
        toolId: 'saturation',
        params: {'red': 1.05, 'orange': 0.95}, // Natural skin tone balance
        label: 'Warm Skin',
      ),
      const EditStep(
        toolId: 'sharpen_mask',
        params: {'radius': 0.3, 'strength': 0.15}, // Preserves pores/texture
        label: 'Preserve Texture',
      ),
      const EditStep(
        toolId: 'grain',
        params: {'intensity': 0.08, 'size': 0.12}, // Adds biological noise
        label: 'Film Grain',
      ),
    ],
  );
}
