import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:easy_localization/easy_localization.dart';

class MakeupStudioScreen extends StatefulWidget {
  final String imagePath;
  const MakeupStudioScreen({super.key, required this.imagePath});

  @override
  State<MakeupStudioScreen> createState() => _MakeupStudioScreenState();
}

class _MakeupStudioScreenState extends State<MakeupStudioScreen> {
  Color _lipColor = AppColors.transparent;
  double _lipstickIntensity = 0.0;
  double _blushIntensity = 0.0;
  final bool _isProcessing = false;

  final List<Color> _lipstickPalette = [
    const Color(0xFFB03060), // Maroon
    const Color(0xFFDC143C), // Crimson
    const Color(0xFFFF69B4), // HotPink
    const Color(0xFFFFB6C1), // LightPink
    const Color(0xFFCD5C5C), // IndianRed
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.makeup.tutorial_title'),
        description: context.tr('tools.makeup.tutorial_desc'),
        icon: AppIcons.brush,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.makeup.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Image.file(File(widget.imagePath)),
                   // Lipstick Overlay simulation
                   if (_lipColor != AppColors.transparent)
                     Opacity(
                       opacity: _lipstickIntensity * 0.4,
                       child: ColorFiltered(
                         colorFilter: ColorFilter.mode(_lipColor, BlendMode.softLight),
                         child: Image.file(File(widget.imagePath)),
                       ),
                     ),
                   // Blush Overlay
                   if (_blushIntensity > 0)
                     Opacity(
                       opacity: _blushIntensity * 0.2,
                       child: ColorFiltered(
                         colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.overlay),
                         child: Image.file(File(widget.imagePath)),
                       ),
                     ),
                ],
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
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaletteRow(context.tr('tools.makeup.lipstick'), _lipstickPalette),
          const SizedBox(height: 24),
          _buildSlider(context.tr('tools.makeup.lipstick_intensity'), _lipstickIntensity, (v) => setState(() => _lipstickIntensity = v)),
          const SizedBox(height: 16),
          _buildSlider(context.tr('tools.makeup.blush_intensity'), _blushIntensity, (v) => setState(() => _blushIntensity = v)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaletteRow(String label, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontFamily: 'VT323', color: AppColors.textSecondary.withValues(alpha: 0.38), fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = _lipColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() => _lipColor = color);
                  HapticsUtility.dialClick();
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.1), width: isSelected ? 3 : 1),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.38), fontSize: 10, letterSpacing: 1.5)),
        Slider(
          value: value,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.textPrimary.withValues(alpha: 0.1),
          onChanged: (v) {
            onChanged(v);
            HapticsUtility.lightFeedback();
          },
        ),
      ],
    );
  }
}
