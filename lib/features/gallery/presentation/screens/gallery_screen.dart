import 'package:xingcam/core/utils/haptics_utility.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/features/gallery/presentation/bloc/gallery_cubit.dart';
import 'package:xingcam/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:xingcam/features/retro_camera/domain/entities/captured_photo.dart';
import 'package:xingcam/core/services/aesthetic_culler_service.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xingcam/core/services/recipe_snatcher_service.dart';
import 'package:xingcam/core/services/recipe_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedPaths = {};
  Map<String, double> _bestShotScores = {};
  bool _isEvaluating = false;

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
        if (_selectedPaths.isEmpty) _isSelectionMode = false;
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  void _startSelection(String path) {
    setState(() {
      _isSelectionMode = true;
      _selectedPaths.add(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(
          title: _isSelectionMode 
              ? context.plural('gallery.selected', _selectedPaths.length, args: [_selectedPaths.length.toString()])
              : context.tr('features.gallery'),
          actions: [
            if (!_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.gold),
                onPressed: _importRecipeFromPhoto,
                tooltip: 'Hút công thức từ ảnh',
              ),
              IconButton(
                icon: const Icon(AppIcons.live, color: AppColors.primary),
                onPressed: () => context.push('/video-recorder'),
              ),
              IconButton(
                icon: Icon(_isEvaluating ? AppIcons.hourglass : AppIcons.ai, color: AppColors.gold),
                onPressed: _evaluateGallery,
                tooltip: context.tr('gallery.evaluate_tooltip'),
              ),
              IconButton(
                icon: const Icon(AppIcons.layout, color: AppColors.primary),
                onPressed: () => context.push('/batch-edit', extra: _selectedPaths.toList()),
              ),
            ],
            if (_isSelectionMode)
              IconButton(
                icon: const Icon(AppIcons.delete, color: AppColors.error),
                onPressed: () {},
              ),
          ],
        ),
        body: Column(
          children: [
            if (_bestShotScores.isNotEmpty) _buildBestShotRibbon(),
            Expanded(
              child: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            if (state is GalleryInitial) {
              context.read<GalleryCubit>().loadPhotos();
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is GalleryLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is GalleryLoaded) {
              if (state.photos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.gallery, size: 80, color: AppColors.textSecondary.withOpacity(0.1)),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('gallery.empty_title'),
                        style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('gallery.empty_subtitle'),
                        style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }
              return _GalleryGrid(
                photos: state.photos,
                isSelectionMode: _isSelectionMode,
                selectedPaths: _selectedPaths,
                bestShotScores: _bestShotScores, // Pass scores for temporal logic
                onSelect: _toggleSelection,
                onLongPress: _startSelection,
              );
            }
            if (state is GalleryError) {
              return Center(child: Text(context.tr(state.message), style: const TextStyle(color: AppColors.textPrimary)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
            ],
          ),
      ),
    );
  }

  Future<void> _importRecipeFromPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final recipe = await RecipeSnatcherService.snatchRecipeFromPhoto(image.path);
    if (!mounted) return;

    if (recipe != null) {
      // Save it to our local recipes
      await RecipeService.saveRecipe(recipe);
      HapticsUtility.successFanfare();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã hút thành công công thức: ${recipe.name}'),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticsUtility.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ảnh này không chứa công thức XingCam ẩn.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _evaluateGallery() async {
    final state = context.read<GalleryCubit>().state;
    if (state is! GalleryLoaded) return;

    setState(() => _isEvaluating = true);
    
    try {
      final paths = state.photos.map((p) => p.path).toList();
      final bestShots = await AestheticCullerService.findBestShots(paths);
      
      setState(() {
        _bestShotScores = bestShots;
      });

      if (mounted && bestShots.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('gallery.evaluate_success', args: [bestShots.length.toString()])),
            backgroundColor: AppColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  void _cullNonHighlights() {
    if (_bestShotScores.isEmpty) return;
    final state = context.read<GalleryCubit>().state;
    if (state is! GalleryLoaded) return;

    setState(() {
      _isSelectionMode = true;
      for (final photo in state.photos) {
        if (!_bestShotScores.containsKey(photo.path)) {
          _selectedPaths.add(photo.path);
        }
      }
    });
    HapticsUtility.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('gallery.cull_identified', args: [_selectedPaths.length.toString()])),
        backgroundColor: AppColors.error.withOpacity(0.8),
      ),
    );
  }


  Widget _buildBestShotRibbon() {
    final bestEntries = _bestShotScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topPhotos = bestEntries.take(5).toList();

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('gallery.best_shots').toUpperCase(), 
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                Row(
                  children: [
                    // Cull Matrix (Phase 202)
                    GestureDetector(
                      onTap: _cullNonHighlights,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(context.tr('gallery.cull_trash').toUpperCase(), 
                          style: const TextStyle(fontFamily: 'Outfit', color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _bestShotScores.clear()),
                      child: Text(context.tr('common.clear').toUpperCase(), 
                        style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: topPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = topPhotos[index];
                return GestureDetector(
                  onTap: () => context.push('/photo-detail', extra: entry.key),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(image: FileImage(File(entry.key)), fit: BoxFit.cover),
                      border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(AppIcons.star, color: AppColors.gold, size: 14),
                        ),
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

class _GalleryGrid extends StatefulWidget {
  final List<CapturedPhoto> photos;
  final bool isSelectionMode;
  final Set<String> selectedPaths;
  final Map<String, double> bestShotScores;
  final Function(String) onSelect;
  final Function(String) onLongPress;

  const _GalleryGrid({
    required this.photos,
    required this.isSelectionMode,
    required this.selectedPaths,
    required this.bestShotScores,
    required this.onSelect,
    required this.onLongPress,
  });

  @override
  State<_GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<_GalleryGrid> {
  Map<String, List<CapturedPhoto>> _groupPhotosByDate() {
    final Map<String, List<CapturedPhoto>> groups = {};
    for (final photo in widget.photos) {
      final dateStr = DateFormat('yyyy-MM-dd').format(photo.timestamp);
      groups.putIfAbsent(dateStr, () => []).add(photo);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupPhotosByDate();
    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return GestureDetector(
      onPanStart: widget.isSelectionMode ? (_) => HapticsUtility.dialClick() : null,
      onPanEnd: widget.isSelectionMode ? (_) => HapticsUtility.leverWind() : null,
      child: CustomScrollView(
        slivers: sortedDates.expand((date) {
          final groupPhotos = groups[date]!;
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatHeaderDate(date), 
                      style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    if (widget.isSelectionMode)
                      GestureDetector(
                        onTap: () => _selectGroup(groupPhotos),
                        child: Text('Select Day', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final photo = groupPhotos[index];
                  final isSelected = widget.selectedPaths.contains(photo.path);
                  final score = widget.bestShotScores[photo.path];
                  
                  return GalleryPhotoItem(
                    imagePath: photo.path,
                    filterName: '',
                    timestamp: photo.timestamp,
                    isSelected: isSelected,
                    isSelectionMode: widget.isSelectionMode,
                    aestheticScore: score,
                    onTap: () => widget.isSelectionMode ? widget.onSelect(photo.path) : null,
                    onLongPress: () => widget.onLongPress(photo.path),
                  );
                },
                childCount: groupPhotos.length,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  String _formatHeaderDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'TODAY';
    return DateFormat('MMMM dd, yyyy').format(date).toUpperCase();
  }

  void _selectGroup(List<CapturedPhoto> group) {
    for (final photo in group) {
      if (!widget.selectedPaths.contains(photo.path)) widget.onSelect(photo.path);
    }
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.gallery,
                color: AppColors.surfaceLight, size: 44),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('gallery.no_photos'),
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('gallery.cta_desc'),
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.surfaceLight,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/camera'),
            icon: const Icon(AppIcons.camera),
            label: Text(context.tr('gallery.open_camera'),
                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬ Photo grid item (used when photos are available) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

class GalleryPhotoItem extends StatelessWidget {
  final String imagePath;
  final String filterName;
  final DateTime timestamp;
  final bool isSelected;
  final bool isSelectionMode;
  final double? aestheticScore;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GalleryPhotoItem({
    super.key,
    required this.imagePath,
    required this.filterName,
    required this.timestamp,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.aestheticScore,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/photo-detail', extra: imagePath),
      onLongPress: onLongPress,
      child: Hero(
        tag: isSelectionMode ? 'selection_$imagePath' : 'photo_$imagePath',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceDeep,
                  child: const Icon(AppIcons.noPhoto, color: AppColors.textSecondary),
                ),
              ),
              // Filter badge overlay
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    filterName,
                    style: TextStyle(fontFamily: 'Outfit', 
                        color: AppColors.textPrimary, fontSize: 9, letterSpacing: 0.5),
                  ),
                ),
              ),
              if (isSelectionMode)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLow.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textPrimary, width: 1.5),
                    ),
                    child: Icon(
                      isSelected ? AppIcons.check : null,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}



