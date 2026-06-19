import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class AiOutfitScreen extends StatefulWidget {
  final String imagePath;
  const AiOutfitScreen({super.key, required this.imagePath});

  @override
  State<AiOutfitScreen> createState() => _AiOutfitScreenState();
}

class _AiOutfitScreenState extends State<AiOutfitScreen> {
  int _selectedStyle = 0;
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _styles = [
    {'label': 'tools.outfit.styles.business', 'icon': AppIcons.library, 'color': AppColors.outfitBusiness},
    {'label': 'tools.outfit.styles.streetwear', 'icon': AppIcons.library, 'color': AppColors.outfitStreet},
    {'label': 'tools.outfit.styles.vintage', 'icon': AppIcons.camera, 'color': AppColors.outfitVintage},
    {'label': 'tools.outfit.styles.summer', 'icon': AppIcons.light, 'color': AppColors.outfitSummer},
    {'label': 'tools.outfit.styles.cyberpunk', 'icon': AppIcons.accent, 'color': AppColors.outfitCyber},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.outfit.tutorial_title'),
        description: context.tr('tools.outfit.tutorial_desc'),
        icon: AppIcons.library,
      );
    });
  }

  void _generateOutfit() {
    setState(() => _isGenerating = true);
    HapticsUtility.dialClick();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isGenerating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('tools.outfit.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  if (_isGenerating)
                    Container(
                      color: AppColors.background.withValues(alpha: 0.45),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 20),
                          Text(context.tr('tools.outfit.fitting'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.primary, fontSize: 24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('tools.outfit.style_theme'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _styles.length,
              itemBuilder: (ctx, i) {
                final s = _styles[i];
                final isSelected = _selectedStyle == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStyle = i);
                    _generateOutfit();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    width: 76,
                    decoration: BoxDecoration(
                      color: isSelected ? (s['color'] as Color).withValues(alpha: 0.15) : AppColors.textPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? (s['color'] as Color) : AppColors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s['icon'] as IconData, color: isSelected ? (s['color'] as Color) : AppColors.textSecondary.withValues(alpha: 0.38), size: 30),
                        const SizedBox(height: 4),
                        Text(context.tr(s['label'] as String), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
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
}


