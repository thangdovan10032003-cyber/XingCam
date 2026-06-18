import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class CollageEditorScreen extends StatefulWidget {
  const CollageEditorScreen({super.key});

  @override
  State<CollageEditorScreen> createState() => _CollageEditorScreenState();
}

class _CollageEditorScreenState extends State<CollageEditorScreen> {
  int _selectedLayout = 0;
  double _spacing = 4.0;
  double _cornerRadius = 0.0;

  final List<Map<String, dynamic>> _layouts = [
    {'label': '2x1', 'slots': 2, 'crossAxis': 2},
    {'label': '1x2', 'slots': 2, 'crossAxis': 1},
    {'label': '2x2', 'slots': 4, 'crossAxis': 2},
    {'label': '3x1', 'slots': 3, 'crossAxis': 3},
    {'label': '2+1', 'slots': 3, 'crossAxis': 2},
    {'label': '3x2', 'slots': 6, 'crossAxis': 3},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('ai_home.tools.collage.tutorial_title'),
        description: context.tr('ai_home.tools.collage.tutorial_desc'),
        icon: AppIcons.filter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = _layouts[_selectedLayout];
    final slots = layout['slots'] as int;
    final crossAxis = layout['crossAxis'] as int;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('ai_home.tools.collage.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('ai_home.tools.smart_crop.export'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: _spacing,
                    mainAxisSpacing: _spacing,
                    childAspectRatio: 1,
                  ),
                  itemCount: slots,
                  itemBuilder: (ctx, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(_cornerRadius),
                      child: Container(
                        color: AppColors.surfaceLight.withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.addPhoto, color: AppColors.textSecondary, size: 32),
                            const SizedBox(height: 8),
                            Text('${context.tr('ai_home.tools.collage.photo_label')} ${i + 1}', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('ai_home.tools.collage.layout'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _layouts.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedLayout == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLayout = i);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.surfaceLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.transparent),
                    ),
                    child: Text(
                      _layouts[i]['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppSlider(
            label: context.tr('ai_home.tools.collage.spacing'),
            value: _spacing / 20.0,
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _spacing = v * 20.0);
              HapticsUtility.lightFeedback();
            },
            suffix: '${_spacing.toInt()}px',
          ),
          AppSlider(
            label: context.tr('ai_home.tools.collage.radius'),
            value: _cornerRadius / 24.0,
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _cornerRadius = v * 24.0);
              HapticsUtility.lightFeedback();
            },
            suffix: '${_cornerRadius.toInt()}px',
          ),
        ],
      ),
    );
  }
}



