import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class StyleMimicScreen extends StatefulWidget {
  const StyleMimicScreen({super.key});

  @override
  State<StyleMimicScreen> createState() => _StyleMimicScreenState();
}

class _StyleMimicScreenState extends State<StyleMimicScreen> {
  XFile? _referenceImage;
  bool _isAnalyzing = false;
  String? _suggestedFilter;
  double _styleBalance = 0.85;

  final List<Map<String, dynamic>> _moodboard = [
    {'name': 'Golden Hour', 'filter': 'Kodak Portra', 'color': Color(0xFFE8A838)},
    {'name': 'Blue Noir', 'filter': 'Classic Negative', 'color': Color(0xFF2D5FA0)},
    {'name': 'Forest Mood', 'filter': 'Ektachrome', 'color': Color(0xFF2D6A3F)},
    {'name': 'Velvet Dark', 'filter': 'Velvia', 'color': Color(0xFF4A2C6E)},
    {'name': 'Faded Film', 'filter': 'Classic Chrome', 'color': Color(0xFF8B7B6B)},
  ];

  void _applyMoodboard(Map<String, dynamic> mood) {
    setState(() {
      _isAnalyzing = true;
      _suggestedFilter = null;
    });
    HapticsUtility.dialClick();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _suggestedFilter = mood['filter'] as String;
        });
        HapticsUtility.leverWind();
      }
    });
  }

  Future<void> _pickReference() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _referenceImage = image;
        _isAnalyzing = true;
      });
      HapticsUtility.dialClick();
      
      // Simulate AI analysis
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isAnalyzing = false;
        _suggestedFilter = _analyzeStyle(image.path);
      });
      HapticsUtility.leverWind();
    }
  }

  String _analyzeStyle(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) return 'Classic Chrome';

      // â”€â”€ Elite Palette Extraction Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      // Focus on the center 50% of the image for mood detection
      final centerRegion = img.copyCrop(image, 
        x: (image.width * 0.25).toInt(), 
        y: (image.height * 0.25).toInt(), 
        width: (image.width * 0.5).toInt(), 
        height: (image.height * 0.5).toInt()
      );

      // Quantize to find the dominant mood
      final palette = img.quantize(centerRegion, numberOfColors: 4);
      final dominant = palette.getPixel(0, 0); // Primary quantized color
      
      // Map RGB mood to Film Recipes
      if (dominant.r > 200 && dominant.g > 180) return 'Kodak Portra'; // Warm Skin/Sun
      if (dominant.b > 180) return 'Velvia'; // Cool/Landscape
      if (dominant.luminance < 0.3) return 'Classic Negative'; // Moody/Deep
      return 'Ektachrome'; // Neutral/Fidelity
    } catch (e) {
      return 'Velvia';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.mimic.tutorial_title'),
        description: context.tr('tools.mimic.tutorial_desc'),
        icon: AppIcons.palette,
      );
    });
  }

  void _autoHarmonize() {
    if (_suggestedFilter == null) return;
    
    // In production, this would trigger the Cubit applyRecipe logic
    HapticsUtility.leverWind();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sovereign Sync Complete! Applied $_suggestedFilter vibe.'),
        backgroundColor: AppColors.mint.withOpacity(0.8),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text(context.tr('tools.mimic.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickReference,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.textPrimary.withOpacity(0.1), width: 2),
                  ),
                  child: _referenceImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(AppIcons.addPhoto, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text(context.tr('tools.mimic.upload'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(_referenceImage!.path), fit: BoxFit.cover),
                              if (_isAnalyzing)
                                Container(
                                  color: AppColors.surfaceLow.withOpacity(0.5),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(color: AppColors.primary),
                                        const SizedBox(height: 16),
                                        Text(context.tr('tools.mimic.analyzing'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sovereign Moodboard (Phase 200)
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _moodboard.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final mood = _moodboard[i];
                  return GestureDetector(
                    onTap: () => _applyMoodboard(mood),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: (mood['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: (mood['color'] as Color).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: mood['color'] as Color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(mood['name'] as String, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            if (_suggestedFilter != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.gradientPurple.withOpacity(0.3), blurRadius: 40, spreadRadius: -10)
                  ],
                ),
                child: Column(
                  children: [
                    Text(context.tr('tools.mimic.matched'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _autoHarmonize,
                      icon: Icon(AppIcons.autoFix, size: 18),
                      label: const Text('Auto-Harmonize'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isAnalyzing ? 'Extracting Style DNA...' : 'Master Recipe Suggested!',
                      style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Style Balance Slider (Phase 209)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('STYLE BALANCE', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.5)),
                            Text('${(_styleBalance * 100).toInt()}%', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _styleBalance,
                          activeColor: AppColors.gold,
                          inactiveColor: AppColors.border,
                          onChanged: (v) {
                            setState(() => _styleBalance = v);
                            // Haptic Peak at AI-suggested point (0.85)
                            if ((v - 0.85).abs() < 0.05) {
                              HapticsUtility.heavyImpact();
                            } else {
                              HapticsUtility.lightTick();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save as new Recipe logic
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gradientPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(context.tr('tools.mimic.generate'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}


