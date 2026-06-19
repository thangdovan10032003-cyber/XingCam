import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/features/gallery/presentation/widgets/provenance_badge.dart';
import 'dart:convert';

class PhotoDetailScreen extends StatelessWidget {
  final String imagePath;
  const PhotoDetailScreen({super.key, required this.imagePath});

  Future<Map<String, dynamic>?> _loadProvenance() async {
    final manifestFile = File('$imagePath.xc2pa.json');
    if (await manifestFile.exists()) {
      return jsonDecode(await manifestFile.readAsString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // â”€â”€ Full-res photo with pinch-to-zoom â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5.0,
                child: Hero(
                  tag: 'photo_$imagePath',
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _IconButtonDark(
                      icon: AppIcons.back,
                      onTap: () => context.pop(),
                    ),
                    const Spacer(),
                    _IconButtonDark(
                      icon: AppIcons.share,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await Share.shareXFiles(
                          [XFile(imagePath)],
                          text: context.tr('sharing.text'),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _IconButtonDark(
                      icon: AppIcons.save,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        try {
                          await Gal.putImage(imagePath, album: 'XingCam');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('common.saved'))),
                            );
                          }
                        } catch (e) {
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('common.error', args: [e.toString()]))),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _IconButtonDark(
                      icon: AppIcons.ai,
                      onTap: () => context.push(
                        '/remove-object',
                        extra: {'imagePath': imagePath},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // â”€â”€ Bottom metadata â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.7),
                      AppColors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      const Icon(AppIcons.check, color: AppColors.primary, size: 8),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('tools.skin_beautifier.desc'),
                        style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _loadProvenance(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return GestureDetector(
                              onTap: () => ProvenanceBadge.show(context, snapshot.data!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mint.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.mint.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(AppIcons.privacy, color: AppColors.mint, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'VERIFIED PROVENANCE',
                                      style: TextStyle(fontFamily: 'Outfit', color: AppColors.mint, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButtonDark extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButtonDark({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

