import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_cubit.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late String _currentPath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          File(_currentPath).existsSync()
              ? Image.file(File(_currentPath), fit: BoxFit.cover)
              : Center(
                  child: Text(context.tr('preview.image_not_found'),
                      style: const TextStyle(color: AppColors.textSecondary))),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _iconBtn(AppIcons.close, () => context.pop()),
                  const Spacer(),
                  _iconBtn(AppIcons.save, () async {
                    try {
                      await Gal.putImage(_currentPath, album: 'XingCam');
                      HapticsUtility.lightTick();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('preview.saved_to_gallery'))),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${context.tr('preview.error_saving')}: $e')),
                        );
                      }
                    }
                  }),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  _iconBtn(AppIcons.ai, () => _showSaveRecipeDialog(context), color: AppColors.primary),
                ],
              ),
            ),
          ),

          // Bottom label (Phase 206: Replaced with Quick Ribbon)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   _buildVibeRibbon(context),
                   const SizedBox(height: 16),
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.check,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(context.tr('preview.photo_captured'),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_isProcessing)
             Container(
               color: Colors.black45,
               child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
             ),
        ],
      ),
    );
  }

  Widget _buildVibeRibbon(BuildContext context) {
    final vibes = [
      {'id': 'auto', 'icon': AppIcons.ai, 'label': 'AUTO'},
      {'id': 'noir', 'icon': AppIcons.filter, 'label': 'NOIR'},
      {'id': 'gold', 'icon': AppIcons.sunflower, 'label': 'GOLDEN'},
      {'id': 'art', 'icon': AppIcons.sculpt, 'label': 'SKETCH'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: vibes.map((v) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => _applyQuickVibe(v['id'] as String),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(v['icon'] as IconData, color: AppColors.textPrimary, size: 20),
                ),
                const SizedBox(height: 6),
                Text(v['label'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Future<void> _applyQuickVibe(String id) async {
    setState(() => _isProcessing = true);
    HapticsUtility.leverWind();
    
    // Simulate high-speed AI processing
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      HapticsUtility.shutter();
    }
  }

  void _showSaveRecipeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('recipe.save_as_title'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: context.tr('recipe.name_hint'),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('common.cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<RetroCameraCubit>().saveCurrentAsRecipe(controller.text);
                HapticsUtility.leverWind();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('recipe.save_success'))),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(context.tr('common.save')),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.2) ?? AppColors.background.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: color != null ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      ),
    );
  }
}
