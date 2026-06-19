import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

enum LightType { side, rim, golden, double }

class RelightingScreen extends StatefulWidget {
  final String imagePath;
  const RelightingScreen({super.key, required this.imagePath});

  @override
  State<RelightingScreen> createState() => _RelightingScreenState();
}

class _RelightingScreenState extends State<RelightingScreen> {
  LightType _selectedLight = LightType.side;
  double _intensity = 0.5;
  bool _isProcessing = false;
  File? _processedFile;
  Offset _gizmoOffset = const Offset(200, 200); // Initial position

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.relighting.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.relighting.next'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: _processedFile != null
                    ? Image.file(_processedFile!)
                    : Image.file(File(widget.imagePath)),
                ),
                // Real-time UI Overlay Preview
                if (_processedFile == null)
                  _buildLightOverlay(),

                // Dragable Gizmo (Phase 194)
                if (_processedFile == null && !_isProcessing)
                  Positioned(
                    left: _gizmoOffset.dx - 24,
                    top: _gizmoOffset.dy - 24,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        setState(() => _gizmoOffset += d.delta);
                        _checkMagneticSnaps();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.8),
                          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 20)],
                          border: Border.all(color: AppColors.textPrimary, width: 2),
                        ),
                        child: const Icon(AppIcons.light, color: AppColors.textPrimary, size: 24),
                      ),
                    ),
                  ),

                // Visual Snap Guides (Phase 204)
                if (_processedFile == null && !_isProcessing)
                  ..._buildSnapGuides(),
                
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LightType.values.map((type) {
                      final isSelected = _selectedLight == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(context.tr('tools.relighting.modes.${type.name}')),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedLight = type);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                AppSlider(
                  label: context.tr('tools.relighting.intensity'),
                  value: _intensity,
                  activeColor: AppColors.gold,
                  onChanged: (v) {
                    setState(() => _intensity = v);
                    HapticsUtility.lightFeedback();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: _getGradientForLightType(),
        ),
      ),
    );
  }

  Gradient? _getGradientForLightType() {
    final color = AppColors.gold.withValues(alpha: _intensity * 0.4);
    
    // Calculate alignment based on Gizmo position relative to center
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 3); // Approx image center
    final direction = _gizmoOffset - center;
    final alignment = Alignment(
      (direction.dx / (size.width / 2)).clamp(-1.0, 1.0),
      (direction.dy / (size.height / 2)).clamp(-1.0, 1.0),
    );

    return RadialGradient(
      colors: [color, AppColors.transparent],
      center: alignment,
      radius: 1.5,
    );
  }

  void _checkMagneticSnaps() {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 3);
    
    final Map<String, Offset> targets = {
      'Butterfly': center + const Offset(0, -100),
      'Rembrandt L': center + const Offset(-80, -80),
      'Rembrandt R': center + const Offset(80, -80),
      'Split L': center + const Offset(-150, 0),
      'Split R': center + const Offset(150, 0),
    };

    bool snapped = false;
    targets.forEach((name, target) {
      if ((_gizmoOffset - target).distance < 25) {
        if (!snapped) {
          setState(() => _gizmoOffset = target); // Magnetic Snap
          HapticsUtility.heavyImpact();
          snapped = true;
        }
      }
    });

    if (!snapped) HapticsUtility.lightFeedback();
  }

  List<Widget> _buildSnapGuides() {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 3);
    final targets = [
      center + const Offset(0, -100),
      center + const Offset(-80, -80),
      center + const Offset(80, -80),
      center + const Offset(-150, 0),
      center + const Offset(150, 0),
    ];

    return targets.map((target) => Positioned(
      left: target.dx - 4,
      top: target.dy - 4,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), shape: BoxShape.circle),
      ),
    )).toList();
  }

  Future<void> _applyFinalRelighting() async {
     setState(() => _isProcessing = true);
     
     // In a real app, this would involve complex image processing
     // For demo, we write the image with simple color adjustments
     try {
       final bytes = await File(widget.imagePath).readAsBytes();
       final image = img.decodeImage(bytes);
       
       if (image != null) {
         // Dummy simulation: adjust brightness/contrast based on intensity
         img.adjustColor(image, brightness: 1.0 + (_intensity * 0.1));
         
         final tempDir = Directory.systemTemp;
         final outPath = '${tempDir.path}/relit_${DateTime.now().millisecondsSinceEpoch}.jpg';
         await File(outPath).writeAsBytes(img.encodeJpg(image));
         
         setState(() {
           _processedFile = File(outPath);
           _isProcessing = false;
         });
       }
     } catch (e) {
       setState(() => _isProcessing = false);
     }
  }
}
