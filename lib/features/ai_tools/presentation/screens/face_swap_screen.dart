import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class FaceSwapScreen extends StatefulWidget {
  final String imagePath;
  const FaceSwapScreen({super.key, required this.imagePath});

  @override
  State<FaceSwapScreen> createState() => _FaceSwapScreenState();
}

class _FaceSwapScreenState extends State<FaceSwapScreen> {
  bool _isProcessing = false;
  int _selectedTargetFace = -1;

  final List<Map<String, dynamic>> _targets = [
    {'name': 'tools.face_swap.targets.celebrity_a', 'icon': AppIcons.beautify},
    {'name': 'tools.face_swap.targets.anime_boy', 'icon': AppIcons.beautify},
    {'name': 'tools.face_swap.targets.vintage_star', 'icon': AppIcons.sculpt},
    {'name': 'tools.face_swap.targets.cosplay_girl', 'icon': AppIcons.beautify},
    {'name': 'tools.face_swap.targets.sketch_mode', 'icon': AppIcons.beautify},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.face_swap.tutorial_title'),
        description: context.tr('tools.face_swap.tutorial_desc'),
        icon: AppIcons.sculpt,
      );
    });
  }

  void _runSwap(int index) {
    setState(() {
      _selectedTargetFace = index;
      _isProcessing = true;
    });
    HapticsUtility.leverWind();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.face_swap.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                  if (_isProcessing)
                    Container(
                      color: AppColors.background.withOpacity(0.54),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.accent),
                          const SizedBox(height: 20),
                          Text(context.tr('tools.face_swap.swapping'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.accent, fontSize: 20)),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('tools.face_swap.select_target'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.38), fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _targets.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedTargetFace == i;
                return GestureDetector(
                  onTap: () => _runSwap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 72,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.textPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_targets[i]['icon'] as IconData, color: isSelected ? AppColors.accent : AppColors.textPrimary.withOpacity(0.7), size: 28),
                        const SizedBox(height: 4),
                        Text(context.tr(_targets[i]['name'] as String), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(AppIcons.addPhoto, size: 18),
              label: Text(context.tr('tools.face_swap.upload_custom'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

