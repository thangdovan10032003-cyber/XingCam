import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class ArtisticBordersScreen extends StatefulWidget {
  final String imagePath;
  const ArtisticBordersScreen({super.key, required this.imagePath});

  @override
  State<ArtisticBordersScreen> createState() => _ArtisticBordersScreenState();
}

class _ArtisticBordersScreenState extends State<ArtisticBordersScreen> {
  int _selectedBorder = 0;
  double _borderWidth = 30.0;

  final List<Map<String, dynamic>> _borders = [
    {'name': 'tools.borders.names.none', 'color': AppColors.transparent, 'type': 'none'},
    {'name': 'tools.borders.names.polaroid', 'color': AppColors.textPrimary, 'type': 'frame', 'bottom': 80.0},
    {'name': 'tools.borders.names.minimal', 'color': AppColors.textPrimary, 'type': 'uniform'},
    {'name': 'tools.borders.names.darkness', 'color': AppColors.background, 'type': 'uniform'},
    {'name': 'tools.borders.names.hacker', 'color': AppColors.mint, 'type': 'uniform'},
    {'name': 'tools.borders.names.dreamy', 'color': AppColors.primary.withValues(alpha: 0.2), 'type': 'blur'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.borders.tutorial_title'),
        description: context.tr('tools.borders.tutorial_desc'),
        icon: AppIcons.ratio,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = _borders[_selectedBorder];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('tools.borders.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.borders.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: border['type'] == 'frame' 
                  ? EdgeInsets.fromLTRB(_borderWidth, _borderWidth, _borderWidth, (border['bottom'] as double))
                  : border['type'] == 'none' ? EdgeInsets.zero : EdgeInsets.all(_borderWidth),
                decoration: BoxDecoration(
                  color: border['type'] == 'blur' ? AppColors.transparent : border['color'] as Color,
                  boxShadow: [
                    if (border['type'] == 'blur') BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 20),
                  ],
                ),
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('tools.borders.frame_style'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.24), fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _borders.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedBorder == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBorder = i);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textPrimary.withValues(alpha: 0.12) : AppColors.textPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.textPrimary.withValues(alpha: 0.7) : AppColors.transparent, width: 2),
                    ),
                    child: Center(
                      child: Text(context.tr(_borders[i]['name'] as String), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(context.tr('tools.borders.width'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.24), fontSize: 11)),
              Expanded(
                child: Slider(
                  value: _borderWidth,
                  min: 0,
                  max: 100,
                  activeColor: AppColors.textPrimary,
                  onChanged: (v) => setState(() => _borderWidth = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


