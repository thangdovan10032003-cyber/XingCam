import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class SpotRemoverScreen extends StatefulWidget {
  final String imagePath;
  const SpotRemoverScreen({super.key, required this.imagePath});

  @override
  State<SpotRemoverScreen> createState() => _SpotRemoverScreenState();
}

class _SpotRemoverScreenState extends State<SpotRemoverScreen> {
  double _smoothness = 0.0;
  double _clarityBoost = 0.0;
  double _brushSize = 0.5;
  final List<Offset> _removedSpots = [];
  bool _isEraseMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.spot.tutorial_title'),
        description: context.tr('tools.spot.tutorial_desc'),
        icon: AppIcons.brush,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.spot.title'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _removedSpots.clear()),
            icon: const Icon(AppIcons.undo, color: AppColors.textPrimary),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.mint, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                if (_isEraseMode) {
                  setState(() => _removedSpots.add(details.localPosition));
                  HapticsUtility.dialClick();
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  // Spot removal indicators
                  CustomPaint(
                    painter: _SpotPainter(_removedSpots),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _ModeBtn(
                label: 'Erase Mode',
                icon: AppIcons.magic,
                isActive: _isEraseMode,
                color: AppColors.mint,
                onTap: () => setState(() => _isEraseMode = true),
              ),
              const SizedBox(width: 12),
              _ModeBtn(
                label: context.tr('tools.spot.pan_mode'),
                icon: AppIcons.magic,
                isActive: !_isEraseMode,
                color: AppColors.accent,
                onTap: () => setState(() => _isEraseMode = false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppSlider(
            label: context.tr('tools.spot.smoothness'),
            value: _smoothness,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _smoothness = v),
          ),
          const SizedBox(height: 16),
          AppSlider(
            label: context.tr('tools.spot.brush_size'),
            value: _brushSize,
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _brushSize = v);
              HapticsUtility.lightFeedback();
            },
          ),
        ],
      ),
    );
  }
}

class _SpotPainter extends CustomPainter {
  final List<Offset> spots;
  _SpotPainter(this.spots);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mint.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    for (final spot in spots) {
      canvas.drawCircle(spot, 18, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.icon, required this.isActive, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : AppColors.textPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isActive ? color : AppColors.textPrimary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? color : AppColors.textSecondary.withOpacity(0.38), size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontFamily: 'Outfit', color: isActive ? color : AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

