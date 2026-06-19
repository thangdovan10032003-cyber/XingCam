import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class SkinToneScreen extends StatefulWidget {
  final String imagePath;
  const SkinToneScreen({super.key, required this.imagePath});

  @override
  State<SkinToneScreen> createState() => _SkinToneScreenState();
}

class _SkinToneScreenState extends State<SkinToneScreen> {
  double _brightness = 0.0;
  double _warmth = 0.0;
  double _rosiness = 0.0;
  int _selectedPreset = -1;

  final List<Map<String, dynamic>> _presets = [
    {'label': 'tools.skin_tone.presets.porcelain', 'b': 0.6, 'w': -0.1, 'r': 0.2, 'color': AppColors.skinPorcelain},
    {'label': 'tools.skin_tone.presets.dewy', 'b': 0.4, 'w': 0.3, 'r': 0.5, 'color': AppColors.skinDewy},
    {'label': 'tools.skin_tone.presets.bronze', 'b': 0.1, 'w': 0.7, 'r': 0.3, 'color': AppColors.skinBronze},
    {'label': 'tools.skin_tone.presets.golden', 'b': 0.3, 'w': 0.6, 'r': 0.1, 'color': AppColors.skinGolden},
    {'label': 'tools.skin_tone.presets.matte', 'b': 0.5, 'w': 0.0, 'r': 0.0, 'color': AppColors.skinMatte},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.skin_tone.tutorial_title'),
        description: context.tr('tools.skin_tone.tutorial_desc'),
        icon: AppIcons.sculpt,
      );
    });
  }

  List<double> get _currentMatrix {
    double r = 1.0 + (_brightness * 0.4) + (_warmth * 0.1) + (_rosiness * 0.05);
    double g = 1.0 + (_brightness * 0.35);
    double b = 1.0 + (_brightness * 0.3) - (_warmth * 0.15) + (_rosiness * 0.05);
    double bias = _brightness * 25;
    return [
      r, 0, 0, 0, bias,
      0, g, 0, 0, bias * 0.8,
      0, 0, b, 0, bias * 0.6,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.skin_tone.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.skin_tone.apply'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(_currentMatrix),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 44),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _presets.length,
              itemBuilder: (ctx, i) {
                final p = _presets[i];
                final isSelected = _selectedPreset == i;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPreset = i;
                      _brightness = p['b'] as double;
                      _warmth = p['w'] as double;
                      _rosiness = p['r'] as double;
                    });
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (p['color'] as Color).withValues(alpha: isSelected ? 0.9 : 0.4),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: isSelected ? AppColors.textPrimary : AppColors.transparent, width: 2),
                    ),
                    child: Text(context.tr(p['label'] as String),
                        style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AppSlider(
            label: context.tr('tools.skin_tone.brightness'),
            value: _brightness,
            activeColor: AppColors.gold,
            onChanged: (v) {
              setState(() {
                _brightness = v;
                _selectedPreset = -1;
              });
              HapticsUtility.lightFeedback();
            },
            suffix: '${(_brightness * 100).toInt()}',
          ),
          const SizedBox(height: 16),
          AppSlider(
            label: context.tr('tools.skin_tone.warmth'),
            value: _warmth,
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() {
                _warmth = v;
                _selectedPreset = -1;
              });
              HapticsUtility.lightFeedback();
            },
            suffix: '${(_warmth * 100).toInt()}',
          ),
          const SizedBox(height: 16),
          AppSlider(
            label: context.tr('tools.skin_tone.rosiness'),
            value: _rosiness,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() {
                _rosiness = v;
                _selectedPreset = -1;
              });
              HapticsUtility.lightFeedback();
            },
            suffix: '${(_rosiness * 100).toInt()}',
          ),
        ],
      ),
    );
  }
}
