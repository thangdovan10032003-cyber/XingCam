import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';

class HairColoristScreen extends StatefulWidget {
  final String imagePath;
  const HairColoristScreen({super.key, required this.imagePath});

  @override
  State<HairColoristScreen> createState() => _HairColoristScreenState();
}

class _HairColoristScreenState extends State<HairColoristScreen> {
  Color? _selectedColor;
  double _intensity = 0.5;

  // Intentional data palette â€” unique cosmetic colours, exempt from tokenization.
  final List<Map<String, dynamic>> _hairColors = [
    {'label': 'tools.hair.colors.jet_black',  'color': const Color(0xFF0A0A0A)},
    {'label': 'tools.hair.colors.espresso',   'color': const Color(0xFF3B1F14)},
    {'label': 'tools.hair.colors.chestnut',   'color': const Color(0xFF7B3F00)},
    {'label': 'tools.hair.colors.honey',      'color': const Color(0xFFD4843C)},
    {'label': 'tools.hair.colors.ash_blonde', 'color': const Color(0xFFE6D5B8)},
    {'label': 'tools.hair.colors.rose_gold',  'color': const Color(0xFFE8A0A0)},
    {'label': 'tools.hair.colors.platinum',   'color': const Color(0xFFE8E8E8)},
    {'label': 'tools.hair.colors.violet',     'color': const Color(0xFF6A0DAD)},
    {'label': 'tools.hair.colors.teal',       'color': const Color(0xFF008080)},
    {'label': 'tools.hair.colors.fire_red',   'color': const Color(0xFFCC0000)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.hair.tutorial_title'),
        description: context.tr('tools.hair.tutorial_desc'),
        icon: AppIcons.sculpt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.hair.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                  if (_selectedColor != null)
                    Opacity(
                      opacity: _intensity * 0.55,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _selectedColor!,
                          BlendMode.hue,
                        ),
                        child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('tools.hair.hair_color'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.38), fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hairColors.length,
              itemBuilder: (ctx, i) {
                final c = _hairColors[i]['color'] as Color;
                final isSelected = _selectedColor == c;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = c);
                    HapticsUtility.dialClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withValues(alpha: 0.24),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 12)]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AppSlider(
            label: context.tr('tools.hair.intensity'),
            value: _intensity,
            activeColor: AppColors.primary,
            onChanged: (v) {
              setState(() => _intensity = v);
              HapticsUtility.lightFeedback();
            },
          ),
        ],
      ),
    );
  }
}
