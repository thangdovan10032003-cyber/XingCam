import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/ai_credit_badge.dart';
import 'package:xingcam/features/ai_tools/presentation/widgets/ai_edit_input.dart';
import 'package:xingcam/core/services/pipeline_context.dart';
import 'package:xingcam/core/services/ai_usage_service.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class AiHomeScreen extends StatefulWidget {
  const AiHomeScreen({super.key});

  @override
  State<AiHomeScreen> createState() => _AiHomeScreenState();
}

class _AiHomeScreenState extends State<AiHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ai_home.categories.all';
  String _searchQuery = '';

  final List<String> _categories = [
    'ai_home.categories.all',
    'ai_home.categories.portrait',
    'ai_home.categories.ai_magic',
    'ai_home.categories.art',
    'ai_home.categories.utility'
  ];

  List<Map<String, dynamic>> _getLocalizedTools(BuildContext context) {
    return [
      {
        'id': 'remove',
        'icon': AppIcons.ai,
        'title': context.tr('ai_home.tools.remover.title'),
        'subtitle': context.tr('ai_home.tools.remover.subtitle'),
        'category': 'ai_home.categories.ai_magic',
        'gradient': [AppColors.primary, AppColors.gradientDeep],
      },
      {
        'id': 'beautify',
        'icon': AppIcons.beautify,
        'title': context.tr('ai_home.tools.beautifier.title'),
        'subtitle': context.tr('ai_home.tools.beautifier.subtitle'),
        'category': 'ai_home.categories.portrait',
        'gradient': [AppColors.accent, AppColors.gradientDeep],
      },
      {
        'id': 'sky',
        'icon': AppIcons.sky,
        'title': context.tr('ai_home.tools.sky.title'),
        'subtitle': context.tr('ai_home.tools.sky.subtitle'),
        'category': 'ai_home.categories.ai_magic',
        'gradient': [AppColors.skyBlue, AppColors.gradientSlateBlue],
      },
      {
        'id': 'relight',
        'icon': AppIcons.light,
        'title': context.tr('ai_home.tools.relighter.title'),
        'subtitle': context.tr('ai_home.tools.relighter.subtitle'),
        'category': 'ai_home.categories.portrait',
        'gradient': [AppColors.sunflower, AppColors.gradientSlateBlue],
      },
      {
        'id': 'gobo',
        'icon': AppIcons.gobo,
        'title': context.tr('ai_home.tools.gobo.title'),
        'subtitle': context.tr('ai_home.tools.gobo.subtitle'),
        'category': 'ai_home.categories.art',
        'gradient': [AppColors.lavender, AppColors.gradientSlateBlue],
      },
      {
        'id': 'sculpt',
        'icon': AppIcons.sculpt,
        'title': context.tr('ai_home.tools.sculptor.title'),
        'subtitle': context.tr('ai_home.tools.sculptor.subtitle'),
        'category': 'ai_home.categories.portrait',
        'gradient': [AppColors.blossom, AppColors.gradientSlateBlue],
      }
    ];
  }

  Future<void> _pickImage(BuildContext context, String toolType) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.push('/$toolType', extra: {'imagePath': image.path});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiUsageService>(
      builder: (context, usageService, _) {
        final tools = _getLocalizedTools(context);
        
        // Resolve Recent Tools
        final recentTools = usageService.recentToolIds
            .map((id) => tools.firstWhere((t) => t['id'] == id, orElse: () => {}))
            .where((t) => t.isNotEmpty)
            .toList();

        final filteredTools = tools.where((tool) {
          final matchesSearch = tool['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == 'ai_home.categories.all' || tool['category'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('ai_home.title'),
                              style: const TextStyle(fontFamily: 'Outfit', 
                                color: AppColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const AiCreditBadge(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // SOVEREIGN PULSE HERO (Phase 206)
                        const SizedBox.shrink(),
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.mdRadius,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: context.tr('ai_home.search_hint'),
                              hintStyle: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
                              prefixIcon: const Icon(AppIcons.search, color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SMART RECENTS SECTION
                        if (usageService.hasRecents && _selectedCategory == 'ai_home.categories.all' && _searchQuery.isEmpty) ...[
                          Text(context.tr('ai_home.recent').toUpperCase(), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentTools.length,
                              itemBuilder: (context, index) {
                                final tool = recentTools[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      usageService.trackToolUsage(tool['id']);
                                      _pickImage(context, tool['id']);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: (tool['gradient'] as List<Color>?) ?? [AppColors.surface, AppColors.border],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(tool['icon'], color: AppColors.textPrimary, size: 24),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(tool['title'].toString().split(' ').last, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Categories
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((catKey) {
                              final isSelected = _selectedCategory == catKey;
                              return Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.sm),
                                child: FilterChip(
                                  label: Text(
                                    context.tr(catKey),
                                    style: TextStyle(fontFamily: 'Outfit', 
                                      color: isSelected ? AppColors.surfaceDeep : AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    HapticsUtility.lightTick();
                                    setState(() => _selectedCategory = catKey);
                                  },
                                  backgroundColor: AppColors.surface,
                                  selectedColor: AppColors.accent,
                                  checkmarkColor: AppColors.surfaceDeep,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.circularRadius,
                                    side: BorderSide(color: isSelected ? AppColors.transparent : AppColors.border),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tool = filteredTools[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _ToolCard(
                            icon: tool['icon'],
                            title: tool['title'],
                            subtitle: tool['subtitle'],
                            onTap: () {
                              usageService.trackToolUsage(tool['id']);
                              _pickImage(context, tool['id']);
                            },
                          ),
                        );
                      },
                      childCount: filteredTools.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AiEditInput(context: PipelineContext()),
          ),
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.03),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontFamily: 'Outfit', 
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Micro-Preview (Phase 199)
                      _buildMicroPreview(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontFamily: 'Outfit', 
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(AppIcons.forward, color: AppColors.border, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroPreview() {
    return Container(
      width: 24,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 2,
            top: 4,
            child: Container(width: 8, height: 6, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          ),
          Positioned(
            right: 2,
            top: 4,
            child: Container(width: 8, height: 6, color: AppColors.accent.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}




