import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class TextStudioScreen extends StatefulWidget {
  final String imagePath;
  const TextStudioScreen({super.key, required this.imagePath});

  @override
  State<TextStudioScreen> createState() => _TextStudioScreenState();
}

class _TextStudioScreenState extends State<TextStudioScreen> {
  String _text = 'Your Story.';
  Color _textColor = AppColors.textPrimary;
  int _selectedFontIndex = 0;
  double _textSize = 28;
  Offset _textPosition = const Offset(0.5, 0.5);
  bool _hasBackground = false;

  final List<TextStyle Function(TextStyle)> _fonts = [
    (s) => s.copyWith(fontFamily: 'Outfit'),
    (s) => s.copyWith(fontFamily: 'PlayfairDisplay'),
    (s) => s.copyWith(fontFamily: 'VT323'),
  ];

  final List<String> _fontNames = ['Outfit', 'Playfair', 'VT323'];

  final List<Color> _colors = [
    AppColors.textPrimary, AppColors.background, AppColors.accent,
    AppColors.primary, AppColors.gold, AppColors.lavender,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.text.tutorial_title'),
        description: context.tr('tools.text.tutorial_desc'),
        icon: AppIcons.textFields,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: _textColor,
      fontSize: _textSize,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(blurRadius: 8, color: AppColors.background.withOpacity(0.54))],
    );
    final appliedStyle = _fonts[_selectedFontIndex](baseStyle);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('tools.text.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
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
            child: GestureDetector(
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  final localPos = details.localPosition;
                  setState(() {
                    _textPosition = Offset(
                      (localPos.dx / box.size.width).clamp(0.0, 1.0),
                      (localPos.dy / box.size.height).clamp(0.0, 1.0),
                    );
                  });
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.cover),
                  Positioned(
                    left: _textPosition.dx * MediaQuery.of(context).size.width - 60,
                    top: _textPosition.dy * (MediaQuery.of(context).size.height * 0.55) - 20,
                    child: Container(
                      padding: _hasBackground ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : EdgeInsets.zero,
                      decoration: _hasBackground
                          ? BoxDecoration(color: AppColors.background.withOpacity(0.54), borderRadius: BorderRadius.circular(8))
                          : null,
                      child: Text(_text, style: appliedStyle),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.tr('tools.text.hint'),
                    hintStyle: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.38)),
                    filled: true,
                    fillColor: AppColors.textPrimary.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _text = v.isEmpty ? context.tr('tools.text.default_text') : v),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _hasBackground = !_hasBackground),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _hasBackground ? AppColors.accent.withOpacity(0.2) : AppColors.surfaceLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _hasBackground ? AppColors.accent : AppColors.transparent),
                  ),
                  child: Icon(AppIcons.borderAll, color: _hasBackground ? AppColors.accent : AppColors.textSecondary.withOpacity(0.38), size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Font row
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _fontNames.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedFontIndex == i;
                return GestureDetector(
                  onTap: () { setState(() => _selectedFontIndex = i); HapticsUtility.dialClick(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.surfaceLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.accent : AppColors.transparent),
                    ),
                    child: Text(_fontNames[i], style: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.accent : AppColors.textSecondary, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Color row and size
          Row(
            children: [
              ..._colors.map((c) => GestureDetector(
                onTap: () { setState(() => _textColor = c); HapticsUtility.dialClick(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: _textColor == c ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.24), width: _textColor == c ? 2.5 : 1),
                  ),
                ),
              )),
              const Spacer(),
              const Icon(AppIcons.textFields, color: AppColors.transparent, size: 16),
              Expanded(
                child: Slider(
                  value: _textSize,
                  min: 12,
                  max: 72,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.surfaceLight.withOpacity(0.1),
                  onChanged: (v) { setState(() => _textSize = v); HapticsUtility.lightFeedback(); },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

