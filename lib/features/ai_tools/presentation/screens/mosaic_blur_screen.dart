import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/services/privacy_shield_service.dart';

class MosaicBlurScreen extends StatefulWidget {
  final String imagePath;
  const MosaicBlurScreen({super.key, required this.imagePath});

  @override
  State<MosaicBlurScreen> createState() => _MosaicBlurScreenState();
}

class _MosaicBlurScreenState extends State<MosaicBlurScreen> {
  final List<_MaskPath> _paths = [];
  int _selectedType = 0; // 0: Mosaic, 1: Gaussian Blur, 2: Dot
  double _brushSize = 30.0;
  bool _isAiProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.mosaic.tutorial_title'),
        description: context.tr('tools.mosaic.tutorial_desc'),
        icon: AppIcons.blur,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.mosaic.title'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _paths.clear()),
            icon: const Icon(AppIcons.undoRounded, color: AppColors.textSecondary),
          ),
          if (!_isAiProcessing)
            IconButton(
              onPressed: _runAiPrivacyShield,
              icon: const Icon(AppIcons.security, color: AppColors.accent),
              tooltip: 'AI Privacy Shield',
            ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  if (_paths.isEmpty || _paths.last.points.length > 50) {
                     _paths.add(_MaskPath(type: _selectedType, points: [], size: _brushSize));
                  }
                  _paths.last.points.add(details.localPosition);
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ClipRect(
                    child: CustomPaint(
                      painter: _MaskPainter(paths: _paths),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModeButton(icon: AppIcons.layout, label: context.tr('tools.mosaic.modes.mosaic'), isSelected: _selectedType == 0, onTap: () => setState(() => _selectedType = 0)),
              const SizedBox(width: 32),
              _ModeButton(icon: AppIcons.blur, label: context.tr('tools.mosaic.modes.blur'), isSelected: _selectedType == 1, onTap: () => setState(() => _selectedType = 1)),
              const SizedBox(width: 32),
              _ModeButton(icon: AppIcons.texture, label: context.tr('tools.mosaic.modes.dot'), isSelected: _selectedType == 2, onTap: () => setState(() => _selectedType = 2)),
            ],
          ),
          const SizedBox(height: 24),
          AppSlider(
            label: context.tr('tools.mosaic.size'),
            value: _brushSize / 100, // Normalized
            activeColor: AppColors.accent,
            onChanged: (v) {
              setState(() => _brushSize = v * 100);
              HapticsUtility.lightFeedback();
            },
            suffix: '${_brushSize.toInt()}px',
          ),
        ],
      ),
    );
  }

  Future<void> _runAiPrivacyShield() async {
    setState(() => _isAiProcessing = true);
    HapticsUtility.dialClick();

    try {
      final faces = await PrivacyShieldService.detectBackgroundFaces(
        imagePath: widget.imagePath,
        imageSize: const Size(1080, 1920), // Placeholder for actual image dimensions
      );

      setState(() {
        for (final rect in faces) {
          // Convert Rect to 4 points for the existing path logic
          _paths.add(_MaskPath(
            type: 0, // Mosaic
            size: rect.width,
            points: [
              Offset(rect.center.dx, rect.center.dy),
              Offset(rect.center.dx + 1, rect.center.dy + 1), // Tiny stroke to trigger painter
            ],
          ));
        }
      });
      HapticsUtility.leverWind();
    } finally {
      setState(() => _isAiProcessing = false);
    }
  }
}

class _MaskPath {
  final int type;
  final List<Offset> points;
  final double size;
  _MaskPath({required this.type, required this.points, required this.size});
}

class _MaskPainter extends CustomPainter {
  final List<_MaskPath> paths;
  _MaskPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (var path in paths) {
      if (path.points.isEmpty) continue;
      final paint = Paint()
        ..strokeWidth = path.size
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (path.type == 0) { // Mosaic simulation
        paint.color = AppColors.textSecondary.withOpacity(0.8);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      } else if (path.type == 1) { // Blur simulation
        paint.color = AppColors.textPrimary.withOpacity(0.15);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      } else { // Dot simulation
        paint.color = AppColors.background;
        paint.strokeWidth = 2;
      }

      final drawPath = Path()..moveTo(path.points.first.dx, path.points.first.dy);
      for (var point in path.points) {
        drawPath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(drawPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeButton({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary.withOpacity(0.3), size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
