import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class WardrobeSyncScreen extends StatefulWidget {
  final String imagePath;
  const WardrobeSyncScreen({super.key, required this.imagePath});

  @override
  State<WardrobeSyncScreen> createState() => _WardrobeSyncScreenState();
}

class _WardrobeSyncScreenState extends State<WardrobeSyncScreen> {
  Color _selectedColor = AppColors.wardrobe;
  double _intensity = 0.5;
  final bool _isAnalyzing = false;

  final List<Color> _harmonies = [
    AppColors.wardrobe,
    AppColors.primary,
    AppColors.accent,
    AppColors.mint,
    AppColors.skyBlue,
    AppColors.secondary,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.wardrobe.tutorial_title'),
        description: context.tr('tools.wardrobe.tutorial_desc'),
        icon: AppIcons.themes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.wardrobe.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.wardrobe, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.file(File(widget.imagePath)),
                // Simulated color tint layer for wardrobe
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedColor.withValues(alpha: _intensity * 0.4),
                      BlendMode.hue,
                    ),
                    child: Container(color: AppColors.transparent),
                  ),
                ),
                // Another layer for saturation/luminance harmony
                 Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedColor.withValues(alpha: _intensity * 0.2),
                      BlendMode.softLight,
                    ),
                    child: Container(color: AppColors.transparent),
                  ),
                ),
              ],
            ),
          ),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr('tools.wardrobe.harmonic'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _harmonies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final color = _harmonies[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    HapticsUtility.dialClick();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : AppColors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15)] : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          AppSlider(
            label: context.tr('tools.wardrobe.intensity'),
            value: _intensity,
            activeColor: AppColors.wardrobe,
            onChanged: (v) {
              setState(() => _intensity = v);
              HapticsUtility.lightFeedback();
            },
          ),
        ],
      ),
    );
  }
}

