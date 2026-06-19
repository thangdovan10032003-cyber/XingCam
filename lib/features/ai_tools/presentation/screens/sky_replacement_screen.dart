import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:easy_localization/easy_localization.dart';

class SkyReplacementScreen extends StatefulWidget {
  final String imagePath;
  const SkyReplacementScreen({super.key, required this.imagePath});

  @override
  State<SkyReplacementScreen> createState() => _SkyReplacementScreenState();
}

class _SkyReplacementScreenState extends State<SkyReplacementScreen> {
  bool _isProcessing = false;
  File? _processedFile;
  String? _selectedSky;
  double _fringeClarity = 0.5;
  bool _autoHarmonize = true;

  final List<Map<String, String>> _skies = [
    {'id': 'sunset', 'name': 'tools.sky.sunset', 'asset': 'assets/sky/sunset.png'},
    {'id': 'starry', 'name': 'tools.sky.starry', 'asset': 'assets/sky/starry_night.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.sky.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.done'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.w700)),
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
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr('tools.sky.select'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _skies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final sky = _skies[index];
                      final isSelected = _selectedSky == sky['id'];
                      return GestureDetector(
                        onTap: () => _applySky(sky),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: AppColors.accent, width: 2) : null,
                                image: DecorationImage(
                                  image: AssetImage(sky['asset']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(context.tr(sky['name']!), style: TextStyle(fontFamily: 'Outfit', color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('tools.sky.harmonize'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                    Switch(
                      value: _autoHarmonize,
                      onChanged: (v) {
                        setState(() => _autoHarmonize = v);
                        if (_selectedSky != null) _reprocessSky();
                      },
                      activeThumbColor: AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(AppIcons.visibility, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Slider(
                        value: _fringeClarity,
                        onChanged: (v) {
                          setState(() => _fringeClarity = v);
                          if (_selectedSky != null) _reprocessSky();
                        },
                        activeColor: AppColors.accent,
                      ),
                    ),
                    const Text('Fringe', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reprocessSky() {
     final sky = _skies.firstWhere((s) => s['id'] == _selectedSky);
    _applySky(sky);
  }

  Future<void> _applySky(Map<String, String> skyData) async {
    setState(() {
      _selectedSky = skyData['id'];
      _isProcessing = true;
    });

    try {
      final imageBytes = await File(widget.imagePath).readAsBytes();
      final sourceImg = img.decodeImage(imageBytes);
      
      final skyAssetBytes = await rootBundle.load(skyData['asset']!);
      final skyImg = img.decodeImage(skyAssetBytes.buffer.asUint8List());

      if (sourceImg != null && skyImg != null) {
        // AI Sky Replacement Simulation
        final result = _processSkySwap(sourceImg, skyImg);
        
        final tempDir = Directory.systemTemp;
        final outPath = '${tempDir.path}/sky_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final outFile = File(outPath);
        await outFile.writeAsBytes(img.encodeJpg(result, quality: 90));

        setState(() {
          _processedFile = outFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  img.Image _processSkySwap(img.Image source, img.Image sky) {
    // Resize sky to match source
    final resizedSky = img.copyResize(sky, width: source.width, height: source.height);
    
    final result = img.Image.from(source);

    for (int y = 0; y < source.height; y++) {
      // Sky is usually in the top part of the image
      // We use a Luma + Color mask: Sky is typically bright and has specific hues
      for (int x = 0; x < source.width; x++) {
        final pixel = source.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // Brightness (Luminance approximation)
        final lum = 0.299 * r + 0.587 * g + 0.114 * b;
        
        // Sky detection logic:
        // 1. High luminance (skies are usually the brightest part)
        // 2. High Blue vs Red (for blue skies) or High Color Balance (for overcast)
        // 3. Proximity to top (we add a weight based on Y coordinate)
        
        double skyConfidence = 0.0;
        
        if (lum > 150) skyConfidence += 0.4;
        if (b > r && b > g) skyConfidence += 0.3; // Blue sky
        
        // Vertical bias: Much more likely to be sky if y < height * 0.6
        final vBias = (1.0 - (y / source.height)).clamp(0.0, 1.0);
        skyConfidence *= vBias;

        // Fringe Clarity Adjustment (Phase 205)
        final threshold = 0.5 - (_fringeClarity * 0.4); // Adaptive threshold
        if (skyConfidence > threshold) {
          final skyPixel = resizedSky.getPixel(x, y);
          // Blend based on confidence for a natural edge
          final blend = (skyConfidence * (1.0 + _fringeClarity)).clamp(0.0, 1.0);
          
          result.setPixelRgba(
            x, y,
            (r * (1 - blend) + skyPixel.r * blend).toInt(),
            (g * (1 - blend) + skyPixel.g * blend).toInt(),
            (b * (1 - blend) + skyPixel.b * blend).toInt(),
            255,
          );
        }
      }
    }
    
    // Atmospheric Harmonization (Phase 198/205)
    if (_autoHarmonize) {
      final skyTint = _extractSkyTint(sky);
      _applyAtmosphericTint(result, skyTint);
    }

    return result;
  }

  Color _extractSkyTint(img.Image sky) {
    // Sample the bottom part of the sky for horizon lighting
    final pixel = sky.getPixel(sky.width ~/ 2, sky.height - 10);
    return Color.fromARGB(pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
  }

  void _applyAtmosphericTint(img.Image image, Color tint) {
    const intensity = 0.15; // Subtle harmonization
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        image.setPixelRgba(
          x, y,
          (pixel.r * (1 - intensity) + tint.red * intensity).toInt(),
          (pixel.g * (1 - intensity) + tint.green * intensity).toInt(),
          (pixel.b * (1 - intensity) + tint.blue * intensity).toInt(),
          pixel.a.toInt(),
        );
      }
    }
  }
}
