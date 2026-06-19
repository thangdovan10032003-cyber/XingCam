import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class PortraitSculptorScreen extends StatefulWidget {
  final String imagePath;
  const PortraitSculptorScreen({super.key, required this.imagePath});

  @override
  State<PortraitSculptorScreen> createState() => _PortraitSculptorScreenState();
}

class _PortraitSculptorScreenState extends State<PortraitSculptorScreen> {
  double _slenderValue = 0.0;
  double _glowValue = 0.0;
  double _heightValue = 0.0; // 0 to 0.15
  double _textureValue = 0.0;
  String? _highlightedKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.sculptor.tutorial_title'),
        description: context.tr('tools.sculptor.tutorial_desc'),
        icon: AppIcons.beautify,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.sculptor.title'),
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Render the slenderized image using a transform
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(0, 0, 1.0 - (_slenderValue * 0.15))
                    ..setEntry(1, 1, 1.0 + (_heightValue * 0.15)),
                  child: GestureDetector(
                    onTapUp: (details) {
                      final y = details.localPosition.dy / 400; // Normalized estimate
                      setState(() {
                         if (y > 0.6) {
                           _highlightedKey = 'slender';
                         } else if (y < 0.3) _highlightedKey = 'glow';
                         else _highlightedKey = 'skin';
                      });
                      HapticsUtility.lightImpact();
                      Future.delayed(const Duration(seconds: 2), () => setState(() => _highlightedKey = null));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(File(widget.imagePath)),
                        // Skin Texture Smoothing (Simulated)
                        if (_textureValue > 0)
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: _textureValue * 4, sigmaY: _textureValue * 4),
                              child: Container(color: AppColors.textPrimary.withValues(alpha: _textureValue * 0.05)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Dream Glow layer
                if (_glowValue > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: _glowValue * 15, sigmaY: _glowValue * 15),
                      child: Container(
                        color: AppColors.textPrimary.withValues(alpha: _glowValue * 0.2),
                      ),
                    ),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            _buildSlider(context.tr('tools.sculptor.slenderize'), _slenderValue, active: _highlightedKey == 'slender', (v) {
              setState(() => _slenderValue = v);
              HapticsUtility.lightTick();
            }),
            const SizedBox(height: 20),
            _buildSlider(context.tr('tools.sculptor.height'), _heightValue, (v) {
              setState(() => _heightValue = v);
              HapticsUtility.lightTick();
            }),
            const SizedBox(height: 20),
            _buildSlider(context.tr('tools.sculptor.elite_skin'), _textureValue, active: _highlightedKey == 'skin', (v) {
              setState(() => _textureValue = v);
              HapticsUtility.lightTick();
            }),
            const SizedBox(height: 20),
            _buildSlider(context.tr('tools.sculptor.dream_glow'), _glowValue, active: _highlightedKey == 'glow', (v) {
              setState(() => _glowValue = v);
              HapticsUtility.lightTick();
            }),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged, {bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withValues(alpha: 0.1) : AppColors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppColors.primary : AppColors.transparent),
      ),
      child: AppSlider(
        label: label,
        value: value,
        activeColor: active ? AppColors.accent : AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
