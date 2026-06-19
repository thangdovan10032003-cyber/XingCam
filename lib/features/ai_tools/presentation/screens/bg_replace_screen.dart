import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'package:xingcam/core/services/on_device_ai_service.dart';

class BgReplaceScreen extends StatefulWidget {
  final String imagePath;
  const BgReplaceScreen({super.key, required this.imagePath});

  @override
  State<BgReplaceScreen> createState() => _BgReplaceScreenState();
}

class _BgReplaceScreenState extends State<BgReplaceScreen> {
  int _selectedBg = -1;
  double _blurIntensity = 0.0;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _backgrounds = [
    {'label': 'ai_home.tools.bg_replace.presets.blur', 'icon': AppIcons.blur, 'color': const Color(0xFF2C3E50)},
    {'label': 'ai_home.tools.bg_replace.presets.beach', 'icon': AppIcons.beach, 'color': const Color(0xFF0080C0)},
    {'label': 'ai_home.tools.bg_replace.presets.city', 'icon': AppIcons.library, 'color': const Color(0xFF1A1A2E)},
    {'label': 'ai_home.tools.bg_replace.presets.forest', 'icon': AppIcons.gallery, 'color': const Color(0xFF1B5E20)},
    {'label': 'ai_home.tools.bg_replace.presets.studio', 'icon': AppIcons.sculpt, 'color': const Color(0xFF424242)},
    {'label': 'ai_home.tools.bg_replace.presets.paris', 'icon': AppIcons.beautify, 'color': const Color(0xFFE8C9A0)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('ai_home.tools.bg_replace.tutorial_title'),
        description: context.tr('ai_home.tools.bg_replace.tutorial_desc'),
        icon: AppIcons.filter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('ai_home.tools.bg_replace.title'),
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background layer
                if (_selectedBg >= 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: (_backgrounds[_selectedBg]['color'] as Color).withValues(alpha: 0.85),
                    child: Icon(
                      _backgrounds[_selectedBg]['icon'] as IconData,
                      size: 120,
                      color: AppColors.surfaceLight.withValues(alpha: 0.12),
                    ),
                  ),
                // Subject (simulated with center crop)
                Center(
                  child: _selectedBg >= 0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 240,
                            child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                          ),
                        )
                      : Image.file(File(widget.imagePath), fit: BoxFit.contain),
                ),
                if (_isProcessing)
                  Container(
                    color: AppColors.background.withValues(alpha: 0.54),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  ),
              ],
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
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('ai_home.tools.bg_replace.choose_bg'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _backgrounds.length,
              itemBuilder: (ctx, i) {
                final bg = _backgrounds[i];
                final isSelected = _selectedBg == i;
                return GestureDetector(
                  onTap: () async {
                    setState(() { _selectedBg = i; _isProcessing = true; });
                    HapticsUtility.dialClick();
                    try {
                      final mask = await getIt<OnDeviceAiService>().segmentSubject(widget.imagePath);
                      if (mounted) {
                        setState(() => _isProcessing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sovereign ML Kit: Processed ${mask?.width}x${mask?.height} mask')),
                        );
                      }
                    } catch (e) {
                      if (mounted) setState(() => _isProcessing = false);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 72,
                    decoration: BoxDecoration(
                      color: (bg['color'] as Color).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(bg['icon'] as IconData, color: AppColors.textPrimary.withValues(alpha: 0.7), size: 24),
                        const SizedBox(height: 4),
                        Text(context.tr(bg['label'] as String),
                            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 9),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AppSlider(
            label: context.tr('ai_home.tools.bg_replace.blur'),
            value: _blurIntensity,
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _blurIntensity = v);
              HapticsUtility.lightFeedback();
            },
          ),
        ],
      ),
    );
  }
}

