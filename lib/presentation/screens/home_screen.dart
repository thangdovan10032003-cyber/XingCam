import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

import 'package:xingcam/core/services/home_feed_service.dart';
import 'package:xingcam/core/services/background_task_service.dart';
import 'package:xingcam/core/services/recipe_service.dart';
import 'package:xingcam/core/widgets/active_task_mini_widget.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _cardController;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  Offset _touchPos = const Offset(0.5, 0.5);

  List<HomeFeedItem> _feedItems = [];
  bool _isLoadingFeed = true;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    _cardController.forward();
    _refreshFeed();
  }

  Future<void> _refreshFeed() async {
    final items = await HomeFeedService.getFeedItems();
    if (mounted) {
      setState(() {
        _feedItems = items;
        _isLoadingFeed = false;
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _touchPos = Offset(
                details.localPosition.dx / MediaQuery.of(context).size.width,
                details.localPosition.dy / MediaQuery.of(context).size.height,
              );
            });
          },
          child: Stack(
            children: [
              // Ambient Orbs
              AnimatedBuilder(
                animation: _bgController,
                builder: (_, __) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _AmbientPainter(progress: _bgController.value, touchPos: _touchPos),
                  );
                },
              ),

              // Content using CustomScrollView for v1.5 Feed
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshFeed,
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. Elegant Header
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'XINGCAM',
                                        style: TextStyle(fontFamily: 'Outfit', 
                                          color: AppColors.textPrimary,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 5,
                                        ),
                                      ),
                                      Text(
                                        context.tr('home.subtitle'),
                                        style: const TextStyle(fontFamily: 'Outfit', 
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _GlassButton(
                                    icon: AppIcons.settings,
                                    onTap: () => context.push('/settings'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Main Tool Box
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              _AnimatedModuleCard(
                                delay: 0,
                                title: context.tr('home.tools.camera.title'),
                                subtitle: context.tr('home.tools.camera.subtitle'),
                                description: context.tr('home.tools.camera.desc'),
                                icon: AppIcons.camera,
                                badge: context.tr('home.badges.offline'),
                                badgeColor: AppColors.mint,
                                gradientColors: const [AppColors.primary, AppColors.gradientPurple],
                                onTap: () => context.push('/camera'),
                              ),
                              const SizedBox(height: 16),
                              _AnimatedModuleCard(
                                delay: 100,
                                title: context.tr('home.tools.ai.title'),
                                subtitle: context.tr('home.tools.ai.subtitle'),
                                description: context.tr('home.tools.ai.desc'),
                                icon: AppIcons.ai,
                                badge: context.tr('home.badges.ai'),
                                badgeColor: AppColors.skyBlue,
                                gradientColors: const [AppColors.gradientSlateBlue, AppColors.gradientDeep],
                                onTap: () => context.push('/ai-tools'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. DYNAMIC FEED SECTION (XingCam v1.5)
                      if (_feedItems.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                const Text('DÀNH CHO BẠN', 
                                  style: TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const Spacer(),
                                if (_isLoadingFeed) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                              ],
                            ),
                          ),
                        ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _feedItems[index];
                              if (item.type == HomeFeedItemType.task) {
                                return ActiveTaskMiniWidget(
                                  task: item.data as AiTask,
                                  onTap: () => context.push('/ai-tools'),
                                );
                              }
                              if (item.type == HomeFeedItemType.recipe) {
                                return _RecipeFeedCard(recipe: item.data as EditRecipe);
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: _feedItems.length,
                          ),
                        ),
                      ),

                      // 4. Gallery Quick Access
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                          child: _GalleryQuickCard(onTap: () => context.push('/gallery')),
                        ),
                      ),

                      // Spacer
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ),

              // Footer (Global overlay)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    context.tr('common.powered_by'),
                    style: const TextStyle(fontFamily: 'Outfit', 
                      color: AppColors.surfaceLight,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
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

// â”€â”€ v1.5 Recipe Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RecipeFeedCard extends StatelessWidget {
  final EditRecipe recipe;
  const _RecipeFeedCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (recipe.previewImagePath != null && File(recipe.previewImagePath!).existsSync())
              Positioned.fill(
                child: Opacity(
                  opacity: 0.4,
                  child: Image.file(File(recipe.previewImagePath!), fit: BoxFit.cover),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(recipe.name, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(RecipeService.describeRecipe(recipe), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.accent, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Animated gradient background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AmbientPainter extends CustomPainter {
  final double progress;
  final Offset touchPos;
  _AmbientPainter({required this.progress, required this.touchPos});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(
      size.width * (touchPos.dx + 0.1 * math.sin(progress * math.pi)),
      size.height * (touchPos.dy + 0.1 * math.cos(progress * math.pi)),
    );
    final p2 = Offset(
      size.width * (0.8 - touchPos.dx * 0.2),
      size.height * (0.2 + touchPos.dy * 0.3),
    );
    _drawOrb(canvas, p1, 200, AppColors.primary.withValues(alpha: 0.18));
    _drawOrb(canvas, p2, 250, AppColors.gradientPurple.withValues(alpha: 0.15));
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, AppColors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.progress != progress;
}

// â”€â”€ Module Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AnimatedModuleCard extends StatefulWidget {
  final int delay;
  final String title, subtitle, description, badge;
  final Color badgeColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final IconData icon;

  const _AnimatedModuleCard({
    required this.delay,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.gradientColors,
    required this.onTap,
    required this.icon,
  });

  @override
  State<_AnimatedModuleCard> createState() => _AnimatedModuleCardState();
}

class _AnimatedModuleCardState extends State<_AnimatedModuleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: AppColors.textPrimary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(fontFamily: 'Outfit', 
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.badgeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: widget.badgeColor.withValues(alpha: 0.5),
                                width: 0.5),
                          ),
                          child: Text(
                            widget.badge,
                            style: TextStyle(fontFamily: 'Outfit', 
                              color: widget.badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(fontFamily: 'Outfit', 
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: TextStyle(fontFamily: 'Outfit', 
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(AppIcons.forward,
                  color: AppColors.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Gallery Quick-Access Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GalleryQuickCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryQuickCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(AppIcons.gallery,
                  color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('home.gallery.title'),
                    style: const TextStyle(fontFamily: 'Outfit', 
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(context.tr('home.gallery.subtitle'),
                    style: const TextStyle(fontFamily: 'Outfit', 
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(AppIcons.chevron,
                color: AppColors.surfaceLight, size: 22),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Glass button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

