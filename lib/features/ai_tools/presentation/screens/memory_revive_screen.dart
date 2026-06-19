import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class MemoryReviveScreen extends StatefulWidget {
  final String imagePath;
  const MemoryReviveScreen({super.key, required this.imagePath});

  @override
  State<MemoryReviveScreen> createState() => _MemoryReviveScreenState();
}

class _MemoryReviveScreenState extends State<MemoryReviveScreen> {
  double _sharpness = 0.0;
  double _denoise = 0.0;
  double _colorPop = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.memory.tutorial_title'),
        description: context.tr('tools.memory.tutorial_desc'),
        icon: AppIcons.history,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.memory.title'),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(AppIcons.check, color: AppColors.accent),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Comparison Slider Simulation
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                       Image.file(File(widget.imagePath), fit: BoxFit.contain),
                       // Simulated Revive Layer (Sharpening/Color)
                       Positioned.fill(
                         child: Opacity(
                           opacity: _colorPop,
                           child: ColorFiltered(
                             colorFilter: const ColorFilter.matrix([
                               1.2, 0, 0, 0, 0,
                               0, 1.2, 0, 0, 0,
                               0, 0, 1.2, 0, 0,
                               0, 0, 0, 1, 0,
                             ]),
                             child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
                if (_isProcessing)
                  const CircularProgressIndicator(color: AppColors.accent),
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
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSlider(context.tr('tools.memory.settings.sharpening'), _sharpness, (v) => setState(() => _sharpness = v)),
          const SizedBox(height: 16),
          _buildSlider(context.tr('tools.memory.settings.denoise'), _denoise, (v) => setState(() => _denoise = v)),
          const SizedBox(height: 16),
          _buildSlider(context.tr('tools.memory.settings.color_pop'), _colorPop, (v) => setState(() => _colorPop = v)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isProcessing = true);
                HapticsUtility.leverWind();
                
                // Smart Revive Engine (Phase 197)
                // Simulate metadata analysis
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _sharpness = 0.65;
                      _denoise = 0.4;
                      _colorPop = 0.3;
                    });
                  }
                });

                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() => _isProcessing = false);
                    HapticsUtility.shutter();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(context.tr('tools.memory.revive'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'VT323', color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5)),
        Slider(
          value: value,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.surfaceLight.withValues(alpha: 0.1),
          onChanged: (v) {
            onChanged(v);
            HapticsUtility.lightFeedback();
          },
        ),
      ],
    );
  }
}
