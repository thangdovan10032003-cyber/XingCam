import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class StyleArtScreen extends StatefulWidget {
  final String imagePath;
  const StyleArtScreen({super.key, required this.imagePath});

  @override
  State<StyleArtScreen> createState() => _StyleArtScreenState();
}

class _StyleArtScreenState extends State<StyleArtScreen> {
  int _selectedStyle = -1;
  double _blendIntensity = 0.8;

  final List<Map<String, dynamic>> _styles = [
    {
      'label': 'tools.art.styles.anime',
      'color': const Color(0xFFFF6B9D),
      'matrix': <double>[
        1.5, 0, 0, 0, -30,
        0, 1.2, 0, 0, -10,
        0, 0, 2.0, 0, -20,
        0, 0, 0, 1, 0,
      ],
    },
    {
      'label': 'tools.art.styles.oil_paint',
      'color': const Color(0xFFD4A017),
      'matrix': <double>[
        1.2, 0.1, 0, 0, 0,
        0, 1.1, 0.1, 0, 0,
        0, 0, 0.9, 0, 0,
        0, 0, 0, 1, 0,
      ],
    },
    {
      'label': 'tools.art.styles.watercolor',
      'color': const Color(0xFF64B5F6),
      'matrix': <double>[
        0.8, 0.2, 0.1, 0, 10,
        0.1, 0.8, 0.1, 0, 10,
        0.1, 0.1, 0.9, 0, 10,
        0, 0, 0, 1, 0,
      ],
    },
    {
      'label': 'tools.art.styles.ghibli',
      'color': const Color(0xFF81C784),
      'matrix': <double>[
        1.1, 0, 0, 0, 5,
        0, 1.15, 0, 0, 5,
        0, 0, 0.85, 0, 15,
        0, 0, 0, 1, 0,
      ],
    },
    {
      'label': 'tools.art.styles.sketch',
      'color': const Color(0xFF9E9E9E),
      'matrix': <double>[
        0.3, 0.3, 0.3, 0, 0,
        0.3, 0.3, 0.3, 0, 0,
        0.3, 0.3, 0.3, 0, 0,
        0, 0, 0, 1, 0,
      ],
    },
    {
      'label': 'tools.art.styles.neon',
      'color': const Color(0xFF7B1FA2),
      'matrix': <double>[
        1.8, 0, 0, 0, -40,
        0, 1.0, 0, 0, 0,
        0, 0, 2.0, 0, -30,
        0, 0, 0, 1, 0,
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.art.tutorial_title'),
        description: context.tr('tools.art.tutorial_desc'),
        icon: AppIcons.palette,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = _selectedStyle >= 0 ? _styles[_selectedStyle] : null;
    final matrix = currentStyle?['matrix'] as List<double>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.art.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: matrix != null
                  ? Opacity(
                      opacity: 1.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(File(widget.imagePath), fit: BoxFit.contain),
                          Opacity(
                            opacity: _blendIntensity,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(matrix),
                              child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.file(File(widget.imagePath), fit: BoxFit.contain),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _styles.length,
              itemBuilder: (ctx, i) {
                final style = _styles[i];
                final isSelected = _selectedStyle == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStyle = i);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (style['color'] as Color).withOpacity(0.8),
                          (style['color'] as Color).withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : AppColors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        context.tr(style['label'] as String),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AppSlider(
            label: context.tr('tools.art.blend'),
            value: _blendIntensity,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _blendIntensity = v);
              HapticsUtility.lightFeedback();
            },
          ),
        ],
      ),
    );
  }
}
