import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xingcam/core/services/visual_branding_service.dart';
import 'package:xingcam/core/services/recipe_sharing_service.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:share_plus/share_plus.dart';

class BrandingPreviewBottomSheet extends StatefulWidget {
  final String imagePath;
  final EditRecipe recipe;

  const BrandingPreviewBottomSheet({
    super.key,
    required this.imagePath,
    required this.recipe,
  });

  @override
  State<BrandingPreviewBottomSheet> createState() => _BrandingPreviewBottomSheetState();
}

class _BrandingPreviewBottomSheetState extends State<BrandingPreviewBottomSheet> {
  bool _isProcessing = false;
  File? _previewFile;

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    setState(() => _isProcessing = true);
    final file = await VisualBrandingService.applyBranding(
      inputPath: widget.imagePath,
      recipe: widget.recipe,
    );
    if (mounted) {
      setState(() {
        _previewFile = file;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.share_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              const Text(
                'CHIA SẺ CÔNG THỨC',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Preview
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textPrimary.withOpacity(0.1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : _previewFile != null
                      ? Image.file(_previewFile!, fit: BoxFit.contain)
                      : const Center(child: Text('Lỗi tạo preview')),
            ),
          ),
          const SizedBox(height: 28),

          // Action
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isProcessing || _previewFile == null
                  ? null
                  : () async {
                      await Share.shareXFiles([XFile(_previewFile!.path)],
                          text: 'Check out my custom recipe ${widget.recipe.name} on XingCam!');
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'CHIA SẺ NGAY',
                style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kèm dải Negative Strip giúp bạn bè biết công thức của bạn.',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
