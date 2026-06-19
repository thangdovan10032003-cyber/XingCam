import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class MagicBrushScreen extends StatefulWidget {
  final String imagePath;
  const MagicBrushScreen({super.key, required this.imagePath});

  @override
  State<MagicBrushScreen> createState() => _MagicBrushScreenState();
}

class _MagicBrushScreenState extends State<MagicBrushScreen> {
  final List<_DoodlePath> _paths = [];
  int _selectedBrush = 0;
  double _brushSize = 20.0;

  final List<Map<String, dynamic>> _brushes = [
    {'name': 'tools.magic_brush.brushes.sparkle', 'icon': AppIcons.magic, 'color': AppColors.gold},
    {'name': 'tools.magic_brush.brushes.neon', 'icon': AppIcons.magic, 'color': AppColors.primary},
    {'name': 'tools.magic_brush.brushes.hearts', 'icon': AppIcons.heart, 'color': AppColors.error},
    {'name': 'tools.magic_brush.brushes.stars', 'icon': AppIcons.star, 'color': AppColors.accent},
    {'name': 'tools.magic_brush.brushes.gold', 'icon': AppIcons.paint, 'color': AppColors.gold},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.magic_brush.tutorial_title'),
        description: context.tr('tools.magic_brush.tutorial_desc'),
        icon: AppIcons.brush,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.magic_brush.title'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _paths.clear()),
            icon: const Icon(AppIcons.refresh, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.magic_brush.add'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _paths.add(_DoodlePath(
                    brushType: _selectedBrush,
                    points: [details.localPosition],
                    size: _brushSize,
                  ));
                });
                HapticsUtility.lightFeedback();
              },
              onPanUpdate: (details) {
                setState(() {
                  _paths.last.points.add(details.localPosition);
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  CustomPaint(
                    painter: _MagicBrushPainter(paths: _paths, brushes: _brushes),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('tools.magic_brush.brush_style'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.38), fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _brushes.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedBrush == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBrush = i);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? (_brushes[i]['color'] as Color).withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? (_brushes[i]['color'] as Color) : AppColors.transparent, width: 2),
                    ),
                    child: Icon(_brushes[i]['icon'] as IconData, color: isSelected ? (_brushes[i]['color'] as Color) : AppColors.textSecondary.withValues(alpha: 0.38), size: 24),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AppSlider(
            label: context.tr('tools.magic_brush.size'),
            value: _brushSize / 80,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _brushSize = v * 80);
              HapticsUtility.lightFeedback();
            },
            suffix: '${_brushSize.toInt()}px',
          ),
        ],
      ),
    );
  }
}

class _DoodlePath {
  final int brushType;
  final List<Offset> points;
  final double size;
  _DoodlePath({required this.brushType, required this.points, required this.size});
}

class _MagicBrushPainter extends CustomPainter {
  final List<_DoodlePath> paths;
  final List<Map<String, dynamic>> brushes;
  _MagicBrushPainter({required this.paths, required this.brushes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var path in paths) {
      if (path.points.isEmpty) continue;
      final paint = Paint()
        ..color = brushes[path.brushType]['color'] as Color
        ..strokeWidth = path.size
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (path.brushType == 1) { // Neon
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      }

      final drawPath = Path()..moveTo(path.points.first.dx, path.points.first.dy);
      for (var point in path.points) {
        drawPath.lineTo(point.dx, point.dy);
        
        // Draw stamps for Sparkle/Hearts
        if (path.brushType == 0 || path.brushType == 2 || path.brushType == 3) {
          final stampPainter = TextPainter(
            text: TextSpan(
              text: _getIconChar(brushes[path.brushType]['icon'] as IconData),
              style: TextStyle(
                fontFamily: 'MaterialIcons',
                fontSize: path.size,
                color: (brushes[path.brushType]['color'] as Color).withValues(alpha: 0.4),
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          stampPainter.paint(canvas, Offset(point.dx - path.size/2, point.dy - path.size/2));
        }
      }
      canvas.drawPath(drawPath, paint);
    }
  }

  String _getIconChar(IconData icon) => String.fromCharCode(icon.codePoint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


