import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/services/generative_ai_service.dart';
import 'package:xingcam/core/services/pipeline_context.dart';
import 'package:xingcam/core/models/edit_command.dart';
import 'package:provider/provider.dart';

class SmartCropScreen extends StatefulWidget {
  final String imagePath;
  const SmartCropScreen({super.key, required this.imagePath});

  @override
  State<SmartCropScreen> createState() => _SmartCropScreenState();
}

class _SmartCropScreenState extends State<SmartCropScreen> {
  int _selectedRatio = 0;
  bool _isAiProcessing = false;
  String? _currentDisplayPath;

  final List<Map<String, dynamic>> _ratios = [
    {'label': 'tools.smart_crop.ratios.free', 'ratio': null, 'desc': 'tools.smart_crop.ratios.custom', 'icon': AppIcons.crop},
    {'label': 'tools.smart_crop.ratios.1_1', 'ratio': 1.0, 'desc': 'tools.smart_crop.ratios.insta_post', 'icon': AppIcons.square},
    {'label': 'tools.smart_crop.ratios.4_5', 'ratio': 4 / 5, 'desc': 'tools.smart_crop.ratios.portrait_ig', 'icon': AppIcons.portrait},
    {'label': 'tools.smart_crop.ratios.9_16', 'ratio': 9 / 16, 'desc': 'tools.smart_crop.ratios.story_tiktok', 'icon': AppIcons.phone},
    {'label': 'tools.smart_crop.ratios.16_9', 'ratio': 16 / 9, 'desc': 'tools.smart_crop.ratios.youtube', 'icon': AppIcons.tv},
    {'label': 'tools.smart_crop.ratios.4_3', 'ratio': 4 / 3, 'desc': 'tools.smart_crop.ratios.classic', 'icon': AppIcons.landscape},
    {'label': 'tools.smart_crop.ratios.3_2', 'ratio': 3 / 2, 'desc': 'tools.smart_crop.ratios.dslr', 'icon': AppIcons.camera},
  ];

  @override
  void initState() {
    super.initState();
    _currentDisplayPath = widget.imagePath;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.smart_crop.tutorial_title'),
        description: context.tr('tools.smart_crop.tutorial_desc'),
        icon: AppIcons.crop,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _ratios[_selectedRatio];
    final aspectRatio = ratio['ratio'] as double?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.smart_crop.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.smart_crop.export'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isAiProcessing)
                      const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent, width: 2),
                        ),
                        child: Stack(
                          children: [
                            Image.file(File(widget.imagePath), fit: BoxFit.contain),
                            const SizedBox.shrink(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _buildAiAction(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 44),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _ratios.length,
              itemBuilder: (ctx, i) {
                final r = _ratios[i];
                final isSelected = _selectedRatio == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRatio = i);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : AppColors.textPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.transparent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(r['icon'] as IconData, size: 18, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                        Text(context.tr(r['label'] as String),
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Text(context.tr(r['desc'] as String),
                            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.38), fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAction() {
    final ratio = _ratios[_selectedRatio];
    final aspectRatio = ratio['ratio'] as double?;
    if (aspectRatio == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _isAiProcessing ? null : () => _runAiUncrop(aspectRatio),
        icon: const Icon(AppIcons.magic),
        label: Text(context.tr('tools.smart_crop.ai_uncrop', args: [context.tr(ratio['label'] as String)]), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _runAiUncrop(double targetRatio) async {
    setState(() => _isAiProcessing = true);
    HapticsUtility.dialClick();

    try {
      final uncroppedPath = await GenerativeAiService.uncropImage(
        inputPath: _currentDisplayPath!,
        targetAspectRatio: targetRatio,
      );

      setState(() {
        _currentDisplayPath = uncroppedPath;
      });

      // Update Pipeline for NDE traceability
      if (mounted) {
        Provider.of<PipelineContext>(context, listen: false).addCommand(
          EditCommand(
            type: EditType.transform,
            params: {'subtype': 'uncrop', 'ratio': targetRatio, 'resultPath': uncroppedPath},
          ),
        );
      }
      
      HapticsUtility.leverWind();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('common.error', args: [e.toString()])), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiProcessing = false);
    }
  }
}



