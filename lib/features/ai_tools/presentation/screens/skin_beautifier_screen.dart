import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:xingcam/core/services/memory_armor_service.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/app_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'package:xingcam/core/services/on_device_ai_service.dart';
import 'package:xingcam/core/services/biometric_consent_service.dart';

class SkinBeautifierScreen extends StatefulWidget {
  final String imagePath;

  const SkinBeautifierScreen({super.key, required this.imagePath});

  @override
  State<SkinBeautifierScreen> createState() => _SkinBeautifierScreenState();
}

class _SkinBeautifierScreenState extends State<SkinBeautifierScreen> {
  double _intensity = 0.5;
  bool _isProcessing = false;
  File? _processedFile;
  File? _originalFile;
  
  @override
  void initState() {
    super.initState();
    _originalFile = File(widget.imagePath);
    _processImage(); // Initial process
  }

  Future<void> _processImage() async {
    if (!await BiometricConsentService.ensureConsent(context)) {
      if (mounted) context.pop();
      return;
    }

    setState(() => _isProcessing = true);
    HapticsUtility.leverWind();

    try {
      final faces = await getIt<OnDeviceAiService>().detectFaces(widget.imagePath);
      if (faces.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sovereign ML Kit: No faces detected')),
        );
      }

      final processedPath = await MemoryArmorService.processWithIsolate(
        inputPath: widget.imagePath,
        operationLabel: 'beautify',
        processor: (image) {
          _beautifySkin(image, _intensity);
          return image;
        },
      );

      if (mounted) {
        setState(() {
          _processedFile = File(processedPath);
          _isProcessing = false;
        });
        HapticsUtility.shutter();
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _beautifySkin(img.Image image, double intensity) {
    final temp = img.Image.from(image);
    final radius = (2 + (intensity * 6)).toInt();
    
    img.gaussianBlur(temp, radius: radius);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final blurred = temp.getPixel(x, y);
        
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        
        bool isSkin = (r > 95 && g > 40 && b > 20 && 
                      (r - g).abs() > 15 && r > g && r > b);
        
        if (isSkin) {
          final factor = intensity * 0.8;
          image.setPixelRgba(
            x, y,
            (r * (1 - factor) + blurred.r * factor).toInt(),
            (g * (1 - factor) + blurred.g * factor).toInt(),
            (b * (1 - factor) + blurred.b * factor).toInt(),
            pixel.a.toInt(),
          );
        }
      }
    }
    
    if (intensity > 0.3) {
      img.adjustColor(image, brightness: 1.0 + (intensity * 0.1), contrast: 1.05);
    }

    // Aura Bloom (Phase 204)
    if (intensity > 0.7) {
      final bloomIntensity = (intensity - 0.7) * 2.0; // 0 to 0.6 scale
      img.adjustColor(image, brightness: 1.0 + (bloomIntensity * 0.05), contrast: 1.0 + (bloomIntensity * 0.1));
      // Simulate soft light glow by slight exposure push
      img.adjustColor(image, gamma: 1.0 - (bloomIntensity * 0.1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('tools.skin_beautifier.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.relighting.next'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.w700)),
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
                    : Image.file(_originalFile!),
                ),
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 44),
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _intensity > 0.7
                                ? AppColors.gold
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: (_intensity > 0.7
                                    ? AppColors.gold
                                    : AppColors.primary).withValues(alpha: 0.7),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _intensity > 0.7
                              ? 'Aura Bloom Active'
                              : 'Sovereign Skin Smoothing',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: _intensity > 0.7
                                ? AppColors.gold
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(_intensity * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppSlider(
                  label: '',
                  value: _intensity,
                  activeColor: _intensity > 0.7 ? AppColors.gold : AppColors.primary,
                  onChanged: (v) {
                    setState(() => _intensity = v);
                    _processImage();
                    if (v < 0.3) {
                      HapticsUtility.lightFeedback();
                    } else if (v < 0.7) {
                      HapticsUtility.mediumImpact();
                    } else {
                      HapticsUtility.heavyImpact();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('tools.skin_beautifier.desc'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
