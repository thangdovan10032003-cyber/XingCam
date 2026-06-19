import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class MagicEraserScreen extends StatefulWidget {
  final String imagePath;
  const MagicEraserScreen({super.key, required this.imagePath});

  @override
  State<MagicEraserScreen> createState() => _MagicEraserScreenState();
}

class _MagicEraserScreenState extends State<MagicEraserScreen> {
  final List<Offset> _maskPoints = [];
  bool _isProcessing = false;
  double _brushSize = 25.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.magic_eraser.tutorial_title'),
        description: context.tr('tools.magic_eraser.tutorial_desc'),
        icon: AppIcons.magic,
      );
    });
  }

  void _runEraser() {
    if (_maskPoints.isEmpty) return;
    setState(() => _isProcessing = true);
    HapticsUtility.leverWind();
    
    // Simulate In-painting AI
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _maskPoints.clear();
        });
        HapticsUtility.shutter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.magic_eraser.title'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _maskPoints.clear()),
            icon: const Icon(AppIcons.undo, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: _runEraser,
            child: Text(context.tr('tools.magic_eraser.remove'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                if (_isProcessing) return;
                setState(() => _maskPoints.add(details.localPosition));
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  CustomPaint(
                    painter: _EraserMaskPainter(points: _maskPoints, brushSize: _brushSize),
                  ),
                  if (_isProcessing)
                    Container(
                      color: AppColors.background.withValues(alpha: 0.45),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.accent),
                          const SizedBox(height: 20),
                          Text(context.tr('tools.magic_eraser.removing'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.accent, fontSize: 20)),
                        ],
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
          AppSlider(
            label: context.tr('tools.magic_eraser.brush_size'),
            value: _brushSize / 100,
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
}

class _EraserMaskPainter extends CustomPainter {
  final List<Offset> points;
  final double brushSize;
  _EraserMaskPainter({required this.points, required this.brushSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.5)
      ..strokeWidth = brushSize
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
