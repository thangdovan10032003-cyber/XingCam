import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class TeethWhiteningScreen extends StatefulWidget {
  final String imagePath;
  const TeethWhiteningScreen({super.key, required this.imagePath});

  @override
  State<TeethWhiteningScreen> createState() => _TeethWhiteningScreenState();
}

class _TeethWhiteningScreenState extends State<TeethWhiteningScreen> {
  double _whitening = 0.0;
  double _naturalTone = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.teeth.tutorial_title'),
        description: context.tr('tools.teeth.tutorial_desc'),
        icon: AppIcons.beautify,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.teeth.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontWeight: FontWeight.bold)),
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
                  if (_whitening > 0)
                    ClipPath(
                      clipper: _SmileROIClipper(), // ROI Masking (Phase 196)
                      child: Opacity(
                        opacity: _whitening * 0.35,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix([
                            1, 0, 0, 0, 220 * _whitening,
                            0, 1, 0, 0, 220 * _whitening,
                            0, 0, 1, 0, 220 * _whitening,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                        ),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSlider(
            label: context.tr('tools.teeth.level'),
            value: _whitening,
            activeColor: AppColors.gold,
            onChanged: (v) {
              setState(() => _whitening = v);
              HapticsUtility.lightFeedback();
            },
          ),
          const SizedBox(height: 20),
          _buildPreviewBadge(),
        ],
      ),
    );
  }

  Widget _buildPreviewBadge() {
    int level = (_whitening * 10).toInt();
    String desc = level == 0 ? context.tr('tools.teeth.badges.natural') : level < 4 ? context.tr('tools.teeth.badges.light_polish') : level < 7 ? context.tr('tools.teeth.badges.bright_smile') : context.tr('tools.teeth.badges.hollywood');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(AppIcons.magic, color: AppColors.gold, size: 16),
        const SizedBox(width: 8),
        Text(desc, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.5)),
        Slider(value: value, activeColor: color, inactiveColor: AppColors.textPrimary.withOpacity(0.1), onChanged: onChanged),
      ],
    );
  }
}
class _SmileROIClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Simulated Smile ROI (Center-bottom of the frame)
    final path = Path();
    final center = Offset(size.width / 2, size.height * 0.65);
    final width = size.width * 0.4;
    final height = size.height * 0.15;
    
    path.addOval(Rect.fromCenter(center: center, width: width, height: height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
