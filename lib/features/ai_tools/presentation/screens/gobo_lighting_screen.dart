import 'package:xingcam/core/utils/haptics_utility.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/features/ai_tools/presentation/widgets/gobo_painter.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class GoboLightingScreen extends StatefulWidget {
  final String imagePath;
  const GoboLightingScreen({super.key, required this.imagePath});

  @override
  State<GoboLightingScreen> createState() => _GoboLightingScreenState();
}

class _GoboLightingScreenState extends State<GoboLightingScreen> {
  GoboType _selectedType = GoboType.palm;
  double _intensity = 0.4;
  double _rotation = 0.0;
  double _scale = 1.0;
  String _activePreset = '';

  final List<Map<String, dynamic>> _scenePresets = [
    {'name': 'Studio', 'type': GoboType.palm, 'intensity': 0.5, 'rotation': 0.0, 'scale': 1.2},
    {'name': 'Dusk', 'type': GoboType.blind, 'intensity': 0.7, 'rotation': 0.3, 'scale': 1.5},
    {'name': 'Drama', 'type': GoboType.grid, 'intensity': 0.9, 'rotation': 0.0, 'scale': 1.0},
    {'name': 'Forest', 'type': GoboType.leaves, 'intensity': 0.4, 'rotation': -0.4, 'scale': 2.0},
  ];

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedType = preset['type'] as GoboType;
      _intensity = preset['intensity'] as double;
      _rotation = preset['rotation'] as double;
      _scale = preset['scale'] as double;
      _activePreset = preset['name'] as String;
    });
    HapticsUtility.leverWind();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHelp());
  }

  void _showHelp() {
    TutorialOverlay.show(
      context,
      title: context.tr('tools.gobo.help_title'),
      description: context.tr('tools.gobo.help_desc'),
      icon: AppIcons.gobo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.gobo.title'),
        actions: [
          TextButton(
            onPressed: () {
              context.push('/preview', extra: {'imagePath': widget.imagePath});
            },
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(child: Image.file(File(widget.imagePath))),
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GoboPainter(
                      type: _selectedType,
                      intensity: _intensity,
                      rotation: _rotation,
                      scale: _scale,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scene Presets (Phase 200)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _scenePresets.map((preset) {
                      final isActive = _activePreset == preset['name'];
                      return GestureDetector(
                        onTap: () => _applyPreset(preset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.gold.withOpacity(0.2) : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isActive ? AppColors.gold : AppColors.border, width: 1.5),
                          ),
                          child: Text(
                            preset['name'] as String,
                            style: TextStyle(fontFamily: 'Outfit', color: isActive ? AppColors.gold : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: GoboType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(type.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedType = type);
                          },
                          selectedColor: AppColors.gold.withOpacity(0.3),
                          labelStyle: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.surfaceDeep : AppColors.textSecondary, fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSlider(context.tr('tools.gobo.intensity'), _intensity, (v) {
                  setState(() => _intensity = v);
                  _triggerLadderHaptic(v);
                }),
                _buildSlider(context.tr('tools.gobo.rotation'), _rotation, (v) => _updateRotation(v), min: -3.14, max: 3.14),
                _buildSlider(context.tr('tools.gobo.scale'), _scale, (v) {
                  setState(() => _scale = v);
                  _triggerLadderHaptic((v - 0.5) / 2.5);
                }, min: 0.5, max: 3.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged, {double min = 0, double max = 1}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12)),
            Text(value.toStringAsFixed(2), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.8), fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.gold,
          onChanged: onChanged,
        ),
      ],
    );
  }
  void _updateRotation(double v) {
    const double snapThreshold = 0.15;
    final double snapped;
    
    // Snap to cardinal angles (0, pi/2, pi, -pi/2, -pi)
    if (v.abs() < snapThreshold) {
      snapped = 0.0;
      if (_rotation != 0.0) HapticsUtility.heavyImpact();
    } else if ((v - 1.57).abs() < snapThreshold) {
      snapped = 1.57;
      if (_rotation != 1.57) HapticsUtility.heavyImpact();
    } else if ((v + 1.57).abs() < snapThreshold) {
      snapped = -1.57;
      if (_rotation != -1.57) HapticsUtility.heavyImpact();
    } else {
      snapped = v;
      HapticsUtility.lightTick();
    }
    
    setState(() => _rotation = snapped);
  }

  void _triggerLadderHaptic(double progress) {
    if (progress > 0.8) {
      HapticsUtility.heavyImpact();
    } else if (progress > 0.4) {
      HapticsUtility.mediumImpact();
    } else {
      HapticsUtility.lightImpact();
    }
  }
}

