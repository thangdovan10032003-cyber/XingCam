import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:easy_localization/easy_localization.dart';

class CollectionHarmonizerScreen extends StatefulWidget {
  const CollectionHarmonizerScreen({super.key});

  @override
  State<CollectionHarmonizerScreen> createState() => _CollectionHarmonizerScreenState();
}

class _CollectionHarmonizerScreenState extends State<CollectionHarmonizerScreen> {
  double _exposure = 1.0;
  double _temperature = 0.0;
  bool _isHarmonizing = false;
  int _masterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('tools.collection.tutorial_title'),
        description: context.tr('tools.collection.tutorial_desc'),
        icon: AppIcons.themes,
      );
    });
  }

  void _syncAesthetic() {
    setState(() => _isHarmonizing = true);
    HapticsUtility.leverWind();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isHarmonizing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('ai_home.tools.collection.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('ai_home.tools.collection.render_all'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCollectionGrid(),
          _buildHarmonizationControls(),
        ],
      ),
    );
  }

  Widget _buildCollectionGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final isMaster = index == _masterIndex;
            return GestureDetector(
              onTap: () {
                setState(() => _masterIndex = index);
                HapticsUtility.dialClick();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                   color: isMaster ? AppColors.textPrimary.withOpacity(0.1) : AppColors.textPrimary.withOpacity(0.05),
                    width: isMaster ? 3 : 1,
                  ),
                  boxShadow: isMaster ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 15)] : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Sovereign offline placeholder â€” displays colour-coded swatch instead of network image.
                      // Sovereign offline placeholder (Phase 207: Synchronized Previews)
                      ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          _exposure, 0, 0, 0, 0,
                          0, _exposure, 0, 0, 0,
                          0, 0, _exposure, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                isMaster ? AppColors.accent.withOpacity(0.2) : AppColors.surfaceLow,
                                //_getTemperatureColor(_temperature),
                              ],
                            ),
                          ),
                          child: const Icon(AppIcons.gallery, color: AppColors.border, size: 48),
                        ),
                      ),
                      if (isMaster)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                            child: Text(context.tr('tools.collection.master'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.background, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHarmonizationControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _ManualSlider(
                  label: context.tr('tools.collection.exposure'),
                  value: _exposure,
                  min: 0.5,
                  max: 1.5,
                  onChanged: (v) => setState(() => _exposure = v),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _ManualSlider(
                  label: context.tr('tools.collection.temp'),
                  value: _temperature,
                  min: -0.5,
                  max: 0.5,
                  onChanged: (v) => setState(() => _temperature = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isHarmonizing ? null : _syncAesthetic,
              icon: _isHarmonizing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : const Icon(AppIcons.adjust),
              label: Text(_isHarmonizing ? context.tr('tools.collection.harmonizing') : context.tr('tools.collection.sync_all'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ManualSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.38), fontSize: 10, letterSpacing: 1.5)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.textPrimary.withOpacity(0.1),
          onChanged: (v) {
            onChanged(v);
            HapticsUtility.lightFeedback();
          },
        ),
      ],
    );
  }
}

