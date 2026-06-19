import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_cubit.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_state.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';

import 'package:xingcam/core/services/batch_processing_service.dart';
import 'package:xingcam/core/services/recipe_sharing_service.dart';

class BatchEditScreen extends StatefulWidget {
  final List<String> imagePaths;
  const BatchEditScreen({super.key, required this.imagePaths});

  @override
  State<BatchEditScreen> createState() => _BatchEditScreenState();
}

class _BatchEditScreenState extends State<BatchEditScreen> {
  FilmRecipe? _selectedRecipe;
  bool _isProcessing = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHelp());
  }

  void _showHelp() {
    TutorialOverlay.show(
      context,
      title: 'Batch Workflow',
      description: 'Apply your custom "Recipes" to multiple photos at once. Select a recipe from the bottom and hit Process.',
      icon: AppIcons.layout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('gallery.batch_title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.transparent,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.help, color: AppColors.textSecondary),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(widget.imagePaths[index]), fit: BoxFit.cover),
              ),
            ),
          ),
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _progress, color: AppColors.primary, backgroundColor: AppColors.border),
                  const SizedBox(height: 12),
                  Text(context.tr('gallery.processing_batch').replaceAll('{}', widget.imagePaths.length.toString()), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr('gallery.select_recipe'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 13)),
                const SizedBox(height: 16),
                BlocBuilder<RetroCameraCubit, RetroCameraState>(
                  builder: (context, state) {
                    if (state is! RetroCameraReady) return const SizedBox();
                    final recipes = state.recipes;
                    if (recipes.isEmpty) return Text(context.tr('recipe.no_recipes'), style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.3)));
                    
                    return SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          final isSelected = _selectedRecipe == recipe;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedRecipe = recipe),
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.textPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.transparent),
                              ),
                              child: Center(
                                child: Text(recipe.name, style: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_selectedRecipe == null || _isProcessing) ? null : _runBatchEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.surfaceLight.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(context.tr('gallery.process_btn'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runBatchEdit() async {
    if (_selectedRecipe == null) return;
    
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
    });

    try {
      // 1. Generate Shortcode for the batch
      final shortcode = FilmRecipeSharingService.generateShortcode(
        lutIntensity: 1.0,
        grainAmount: _selectedRecipe!.grainIntensity,
        lightLeakSeed: 123,
      );
      
      // 2. Run Parallel Processing in Isolate
      // Note: We process in smaller chunks or all at once depending on count
      final results = await BatchProcessingService.processBatch(
        inputPaths: widget.imagePaths,
        recipeShortcode: shortcode,
      );

      HapticsUtility.leverWind();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Succesfully processed ${results.length} photos with ${_selectedRecipe!.name}!'),
            backgroundColor: AppColors.mint.withValues(alpha: 0.8),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batch failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

