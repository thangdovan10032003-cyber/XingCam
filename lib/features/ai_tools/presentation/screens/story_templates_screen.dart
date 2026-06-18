import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:easy_localization/easy_localization.dart';

class StoryTemplatesScreen extends StatefulWidget {
  final String imagePath;
  const StoryTemplatesScreen({super.key, required this.imagePath});

  @override
  State<StoryTemplatesScreen> createState() => _StoryTemplatesScreenState();
}

class _StoryTemplatesScreenState extends State<StoryTemplatesScreen> {
  int _selectedTemplate = 0;
  String _captionText = 'tools.story.default_caption';

  final List<Map<String, dynamic>> _templates = [
    {
      'label': 'tools.story.templates.ig_classic',
      'platform': 'IG',
      'accent': const Color(0xFFE1306C),
      'layout': 'full',
      'textPos': Alignment.bottomCenter,
    },
    {
      'label': 'tools.story.templates.tt_bold',
      'platform': 'TT',
      'accent': const Color(0xFF69C9D0),
      'layout': 'header',
      'textPos': Alignment.topCenter,
    },
    {
      'label': 'tools.story.templates.split_duo',
      'platform': 'IG',
      'accent': const Color(0xFF833AB4),
      'layout': 'split',
      'textPos': Alignment.center,
    },
    {
      'label': 'tools.story.templates.cinematic',
      'platform': 'ALL',
      'accent': const Color(0xFFF77737),
      'layout': 'cinematic',
      'textPos': Alignment.bottomLeft,
    },
    {
      'label': 'tools.story.templates.minimal',
      'platform': 'IG',
      'accent': AppColors.textPrimary,
      'layout': 'minimal',
      'textPos': Alignment.bottomCenter,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.story.tutorial_title'),
        description: context.tr('tools.story.tutorial_desc'),
        icon: AppIcons.stories,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tmpl = _templates[_selectedTemplate];
    final accent = tmpl['accent'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('tools.story.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              HapticsUtility.leverWind();
              context.pop();
            },
            icon: const Icon(AppIcons.share, size: 18),
            label: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Preview
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(widget.imagePath), fit: BoxFit.cover),
                    // Cinematic bars
                    if (tmpl['layout'] == 'cinematic') ...[
                      Container(
                        alignment: Alignment.topCenter,
                        child: Container(height: 60, color: AppColors.background.withOpacity(0.87)),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Container(height: 80, color: AppColors.background.withOpacity(0.87)),
                      ),
                    ],
                    // Color overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.transparent,
                            accent.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Caption
                    Align(
                      alignment: tmpl['textPos'] as Alignment,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GestureDetector(
                          onTap: () async {
                            final ctrl = TextEditingController(text: _captionText);
                            await showDialog<String>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text(context.tr('tools.story.caption'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
                                content: TextField(
                                  controller: ctrl,
                                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
                                  cursorColor: accent,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accent)),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() => _captionText = ctrl.text);
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.54),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _captionText,
                              style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Platform badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tmpl['platform'] as String,
                          style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Template Selector
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
            color: AppColors.background,
            child: SizedBox(
              height: 58,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _templates.length,
                itemBuilder: (ctx, i) {
                  final t = _templates[i];
                  final isSelected = _selectedTemplate == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTemplate = i);
                      HapticsUtility.dialClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [(t['accent'] as Color).withOpacity(0.8), (t['accent'] as Color).withOpacity(0.3)],
                              )
                            : null,
                        color: isSelected ? null : AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? (t['accent'] as Color) : AppColors.textPrimary.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        t['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


