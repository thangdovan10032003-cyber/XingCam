import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class BodySculptScreen extends StatefulWidget {
  final String imagePath;
  const BodySculptScreen({super.key, required this.imagePath});

  @override
  State<BodySculptScreen> createState() => _BodySculptScreenState();
}

class _BodySculptScreenState extends State<BodySculptScreen> {
  double _waist = 0.0;
  double _legs = 0.0;
  ui.Image? _image;
  bool _isLoaded = false;
  String? _activeArea;

  @override
  void initState() {
    super.initState();
    _loadImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('ai_home.tools.sculptor.tutorial_title'),
        description: context.tr('ai_home.tools.sculptor.tutorial_desc'),
        icon: AppIcons.gallery,
      );
    });
  }

  Future<void> _loadImage() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('ai_home.tools.sculptor.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _image!.width / _image!.height,
                child: CustomPaint(
                  painter: _MeshLiquifyPainter(
                    image: _image!,
                    waistAmount: _waist,
                    legAmount: _legs,
                    activeArea: _activeArea,
                  ),
                ),
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
          _buildBodySlider(context.tr('ai_home.tools.sculptor.slim_waist'), _waist, AppIcons.sculpt, (v) {
            setState(() {
              _waist = v;
              _activeArea = 'waist';
            });
            _checkSafeZone(v);
            Future.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => _activeArea = null); });
          }),
          const SizedBox(height: 12),
          _buildBodySlider(context.tr('ai_home.tools.sculptor.long_legs'), _legs, AppIcons.sculpt, (v) {
            setState(() {
              _legs = v;
              _activeArea = 'legs';
            });
            _checkSafeZone(v);
            Future.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => _activeArea = null); });
          }),
        ],
      ),
    );
  }

  Widget _buildBodySlider(String label, double value, IconData icon, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent.withValues(alpha: 0.7), size: 18),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            min: -0.5,
            max: 0.5,
            activeColor: AppColors.accent,
            onChanged: (v) {
              onChanged(v);
              HapticsUtility.lightFeedback();
            },
          ),
        ),
      ],
    );
  }
  void _checkSafeZone(double v) {
    if (v.abs() > 0.4) {
      HapticsUtility.heavyImpact(); // Unnatural "Wall"
      Future.delayed(const Duration(milliseconds: 100), () => HapticsUtility.lightImpact());
    } else {
      HapticsUtility.lightTick();
    }
  }
}

class _MeshLiquifyPainter extends CustomPainter {
  final ui.Image image;
  final double waistAmount;
  final double legAmount;
  final String? activeArea;

  _MeshLiquifyPainter({required this.image, required this.waistAmount, required this.legAmount, this.activeArea});

  @override
  void paint(Canvas canvas, Size size) {
    // ... Existing mesh logic ...
    _drawAnatomicalGuides(canvas, size);
    
    const int gridRows = 20;
    const int gridCols = 20;
    
    // Calculate vertices for Mesh Deformation
    final List<Offset> vertices = [];
    final List<Offset> textureCoordinates = [];
    final List<int> indices = [];

    final double stepX = size.width / gridCols;
    final double stepY = size.height / gridRows;

    for (int y = 0; y <= gridRows; y++) {
      for (int x = 0; x <= gridCols; x++) {
        double px = x * stepX;
        double py = y * stepY;

        // Apply Local Deformation Logic (Liquify)
        // Slim Waist: Pull middle-side vertices inward
        double centerY = size.height * 0.45; // Waist area
        double distanceToCenterY = (py - centerY).abs() / (size.height * 0.2);
        if (distanceToCenterY < 1.0) {
          double factor = (1.0 - distanceToCenterY);
          // Only pull the horizontal sides
          if (px < size.width * 0.4) {
             px += factor * waistAmount * 40;
          } else if (px > size.width * 0.6) {
             px -= factor * waistAmount * 40;
          }
        }

        // Lengthen Legs: Push bottom half down
        double legStartY = size.height * 0.6;
        if (py > legStartY) {
          double legFactor = (py - legStartY) / (size.height - legStartY);
          py += legFactor * legAmount * 50;
        }

        vertices.add(Offset(px, py));
        textureCoordinates.add(Offset(x / gridCols * image.width, y / gridRows * image.height));
      }
    }

    // Create triangles for drawVertices
    for (int y = 0; y < gridRows; y++) {
      for (int x = 0; x < gridCols; x++) {
        int i0 = y * (gridCols + 1) + x;
        int i1 = i0 + 1;
        int i2 = i0 + (gridCols + 1);
        int i3 = i2 + 1;
        
        indices.addAll([i0, i1, i2]);
        indices.addAll([i1, i3, i2]);
      }
    }

    final ui.Vertices mesh = ui.Vertices(
      ui.VertexMode.triangles,
      vertices,
      textureCoordinates: textureCoordinates,
      indices: indices,
    );

    final Paint paint = Paint()..shader = ImageShader(image, TileMode.clamp, TileMode.clamp, Matrix4.identity().storage);
    canvas.drawVertices(mesh, BlendMode.src, paint);
  }

  void _drawAnatomicalGuides(Canvas canvas, Size size) {
    if (activeArea == null) return;
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    if (activeArea == 'waist') {
      canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), paint);
    } else if (activeArea == 'legs') {
      canvas.drawRect(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshLiquifyPainter oldDelegate) {
    return oldDelegate.waistAmount != waistAmount || oldDelegate.legAmount != legAmount || oldDelegate.activeArea != activeArea;
  }
}


