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

class EyeBagRemoverScreen extends StatefulWidget {
  final String imagePath;
  const EyeBagRemoverScreen({super.key, required this.imagePath});

  @override
  State<EyeBagRemoverScreen> createState() => _EyeBagRemoverScreenState();
}

class _EyeBagRemoverScreenState extends State<EyeBagRemoverScreen> {
  double _eyeBagRemoval = 0.0;
  double _wrinkleSmooth  = 0.0;
  double _eyeBrightness  = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('ai_home.tools.eye_bag.tutorial_title'),
        description: context.tr('ai_home.tools.eye_bag.tutorial_desc'),
        icon: AppIcons.sculpt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('ai_home.tools.eye_bag.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
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
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  if (_eyeBagRemoval > 0 || _eyeBrightness > 0)
                    Opacity(
                      opacity: (_eyeBagRemoval + _eyeBrightness) * 0.3,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          1.05, 0, 0, 0, 10 * _eyeBrightness,
                          0, 1.05, 0, 0, 10 * _eyeBrightness,
                          0, 0, 1.1, 0, 15 * _eyeBrightness,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                      ),
                    ),
                  if (_wrinkleSmooth > 0)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: _wrinkleSmooth * 1.5, sigmaY: _wrinkleSmooth * 1.5),
                        child: Container(color: AppColors.transparent),
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 50),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabeledSlider(context.tr('ai_home.tools.eye_bag.removal'), _eyeBagRemoval, AppColors.accent,
              (v) { setState(() => _eyeBagRemoval = v); HapticsUtility.lightFeedback(); }),
          _buildLabeledSlider(context.tr('ai_home.tools.eye_bag.smooth'), _wrinkleSmooth, AppColors.primary,
              (v) { setState(() => _wrinkleSmooth = v); HapticsUtility.lightFeedback(); }),
          _buildLabeledSlider(context.tr('ai_home.tools.eye_bag.brighten'), _eyeBrightness, AppColors.accent,
              (v) { setState(() => _eyeBrightness = v); HapticsUtility.lightFeedback(); }),
        ],
      ),
    );
  }

  Widget _buildLabeledSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppSlider(
        label: label,
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }
}
