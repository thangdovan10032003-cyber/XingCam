import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'package:xingcam/core/services/on_device_ai_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ArStickersScreen extends StatefulWidget {
  final String imagePath;
  const ArStickersScreen({super.key, required this.imagePath});

  @override
  State<ArStickersScreen> createState() => _ArStickersScreenState();
}

class _ArStickersScreenState extends State<ArStickersScreen> {
  final List<Offset> _placedStickers = [];
  int _selectedSticker = 0;
  bool _isScanningDepth = false;
  String? _depthMaskPath;

  final List<IconData> _stickers = [
    AppIcons.ai,
    AppIcons.heart,
    AppIcons.star,
    AppIcons.flashOn,
    AppIcons.sunny,
    AppIcons.mood,
    AppIcons.rocket,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateDepthMap();
      TutorialOverlay.show(
        context,
        title: context.tr('tools.ar_stickers.tutorial_title'),
        description: context.tr('tools.ar_stickers.tutorial_desc'),
        icon: AppIcons.magic,
      );
    });
  }

  Future<void> _generateDepthMap() async {
    setState(() => _isScanningDepth = true);
    try {
      final mask = await getIt<OnDeviceAiService>().segmentSubject(widget.imagePath);
      if (mask != null && mask.confidences.isNotEmpty) {
        final tempDir = (await getTemporaryDirectory()).path;
        final outPath = await compute(_buildTransparentMask, {
          'imagePath': widget.imagePath,
          'width': mask.width,
          'height': mask.height,
          'confidences': mask.confidences,
          'tempPath': tempDir,
        });
        if (mounted) {
          setState(() {
            _depthMaskPath = outPath;
            _isScanningDepth = false;
          });
        }
      } else {
        if (mounted) setState(() => _isScanningDepth = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isScanningDepth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('tools.ar_stickers.title'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _placedStickers.clear()),
            icon: const Icon(AppIcons.refresh, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('tools.ar_stickers.apply'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                setState(() => _placedStickers.add(details.localPosition));
                HapticsUtility.dialClick();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ..._placedStickers.map((pos) => Positioned(
                    left: pos.dx - 25,
                    top: pos.dy - 25,
                    child: Icon(_stickers[_selectedSticker], color: AppColors.gold, size: 50, shadows: [Shadow(blurRadius: 10, color: AppColors.background.withValues(alpha: 0.54))]),
                  )),
                  
                  // LAYER 3: Sovereign Foreground Depth Overlay
                  if (_depthMaskPath != null)
                    IgnorePointer(
                      child: Image.file(File(_depthMaskPath!), fit: BoxFit.contain),
                    ),
                    
                  if (_isScanningDepth)
                    Container(
                      color: AppColors.background.withValues(alpha: 0.4),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text('Sovereign ML Kit: Scanning 3D Depth...', style: TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stickers.length,
              itemBuilder: (ctx, i) {
                final isSelected = _selectedSticker == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedSticker = i);
                    HapticsUtility.lightFeedback();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.gold : AppColors.transparent, width: 2),
                    ),
                    child: Icon(_stickers[i], color: isSelected ? AppColors.gold : AppColors.textSecondary, size: 28),
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

Future<String> _buildTransparentMask(Map<String, dynamic> args) async {
  final imagePath = args['imagePath'] as String;
  final width = args['width'] as int;
  final height = args['height'] as int;
  final confidences = args['confidences'] as List<double>; // Use the provided confidences instead of floats directly if dynamic.
  final tempPath = args['tempPath'] as String;

  final originalBytes = await File(imagePath).readAsBytes();
  final originalImg = img.decodeImage(originalBytes)!;
  
  final outImg = img.Image(width: width, height: height, numChannels: 4);
  final resizedOriginal = img.copyResize(originalImg, width: width, height: height);

  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      final conf = confidences[y * width + x];
      // 0.6 Confidence Threshold for subject segmentation
      if (conf > 0.6) {
        final p = resizedOriginal.getPixel(x, y);
        outImg.setPixelRgba(x, y, p.r, p.g, p.b, p.a);
      } else {
        outImg.setPixelRgba(x, y, 0, 0, 0, 0); // Transparent Background!
      }
    }
  }

  // Save as PNG to PRESERVE TRANSPARENCY!
  final outPath = '$tempPath/depth_mask_${DateTime.now().millisecondsSinceEpoch}.png';
  await File(outPath).writeAsBytes(img.encodePng(outImg));
  
  return outPath;
}


