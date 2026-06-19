import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';

class FilterSelector extends StatefulWidget {
  final List<FilterPreset> presets;
  final FilterPreset selected;
  final ValueChanged<FilterPreset> onSelected;

  const FilterSelector({
    super.key,
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  late final ScrollController _scrollController;

  // Approximated tint colors for the thumbnail swatch — just a visual hint.
  static const Map<String, Color> _swatchColors = {
    'none':         Color(0xFF888888),
    'fuji_superia': Color(0xFF70A8B0),
    'kodak_portra': Color(0xFFD4A070),
    'noir':         Color(0xFF555555),
    'warm_summer':  Color(0xFFE88060),
    'cool_fade':    Color(0xFF7090C0),
    'velvia':       Color(0xFF90C050),
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final preset = widget.presets[index];
          final isSelected = preset.id == widget.selected.id;
          final color = _swatchColors[preset.id] ?? AppColors.textSecondary;

          return GestureDetector(
            onTap: () {
              HapticsUtility.dialClick();
              widget.onSelected(preset);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    // Color swatch area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.6),
                              color,
                            ],
                          ),
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(AppIcons.check,
                                    color: AppColors.textPrimary, size: 18))
                            : null,
                      ),
                    ),
                    // Label
                    Container(
                      color: AppColors.surfaceLow.withValues(alpha: 0.5),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        context.tr(preset.name),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
