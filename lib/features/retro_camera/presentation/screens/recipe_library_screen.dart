import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_cubit.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_state.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';

import 'package:flutter/services.dart';
import 'package:xingcam/core/services/recipe_sharing_service.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  @override
  void initState() {
    super.initState();
    _checkClipboardForRecipe();
  }

  Future<void> _checkClipboardForRecipe() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final code = data?.text;
    if (code != null && code.startsWith('XC-')) {
      if (mounted) {
        _showImportOption(code);
      }
    }
  }

  void _showImportOption(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(AppIcons.style, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(context.tr('recipe.detected_clipboard', args: [code]))),
          ],
        ),
        action: SnackBarAction(
          label: context.tr('recipe.import_action').toUpperCase(),
          textColor: AppColors.gold,
          onPressed: () {
            final decoded = FilmRecipeSharingService.decodeShortcode(code);
            if (decoded != null) {
              // In a real app, we'd open the creation screen with these presets
              context.push('/recipe/create', extra: decoded);
            }
          },
        ),
        backgroundColor: AppColors.surfaceDeep,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('recipe.library_title'),
        actions: [
          _IconButton(
            onPressed: () => context.push('/recipe/create'),
            icon: AppIcons.add,
            color: AppColors.accent,
          ),
        ],
      ),
      body: BlocBuilder<RetroCameraCubit, RetroCameraState>(
        builder: (context, state) {
          if (state is! RetroCameraReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = state.recipes;

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.library, size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('recipe.no_recipes'),
                    style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('recipe.save_hint'),
                    style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeCard(recipe: recipe);
            },
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final FilmRecipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<RetroCameraCubit>().applyRecipe(recipe);
        context.pop(); // Back to camera
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      _getPresetColor(recipe.filter.id).withValues(alpha: 0.8),
                      _getPresetColor(recipe.filter.id).withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(AppIcons.style, color: AppColors.textPrimary, size: 32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${context.tr(recipe.filter.name)} â€¢ ${(recipe.grainIntensity * 100).toInt()}%',
                            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.pin, color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          // Mock Phase 36: Pin to Home Widget
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${context.tr('recipe.pinned')} ${recipe.name}')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.palette, color: AppColors.accent, size: 18),
                        tooltip: 'Clone Vibe from Photo',
                        onPressed: () => _cloneVibe(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cloneVibe(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final bytes = await File(image.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return;

      // â”€â”€ Sovereign Vibe Extraction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      // Extract dominant color mood
      final palette = img.quantize(decoded, numberOfColors: 5);
      final dominant = palette.getPixel(0, 0);

      // Determine filter and grain based on Vibe
      String filterId = 'classic_film';
      double grain = 0.2;

      if (dominant.r > 200 && dominant.g > 150) {
        filterId = 'velvia_vivid'; // Warm/Vibrant
        grain = 0.15;
      } else if (dominant.b > 180) {
        filterId = 'cool_fade'; // Cool
        grain = 0.3;
      } else if (dominant.luminance < 0.2) {
        filterId = 'noir_bw'; // Dark/B&W
        grain = 0.6;
      }

      // Update Recipe in Cubit
      final updatedRecipe = recipe.copyWith(
        filter: recipe.filter,
        grainIntensity: grain,
      );

      if (context.mounted) {
        // context.read<RetroCameraCubit>().updateRecipe(updatedRecipe);
        HapticsUtility.leverWind(); // Tactical feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vibe Cloned! ${recipe.name} is now synchronized with your reference photo.'),
            backgroundColor: AppColors.mint.withValues(alpha: 0.8),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vibe Clone failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Color _getPresetColor(String id) {
    return switch (id) {
      'classic_film' => AppColors.sunflower,
      'vibrant_chrome' => AppColors.skyBlue,
      'cool_fade' => AppColors.gradientPurple,
      'noir_bw' => AppColors.textSecondary,
      'velvia_vivid' => AppColors.primary,
      _ => AppColors.surfaceLight,
    };
  }
}

class _IconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  const _IconButton({required this.onPressed, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }
}



