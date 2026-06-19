import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/services/ai_credit_service.dart';
import '../widgets/subscription_paywall_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      icon: AppIcons.camera,
      title: 'onboarding.slides.retro.title',
      subtitle: 'onboarding.slides.retro.subtitle',
      gradientColors: [AppColors.primary, AppColors.gradientPurple],
    ),
    _OnboardSlide(
      icon: AppIcons.filter,
      title: 'onboarding.slides.filters.title',
      subtitle: 'onboarding.slides.filters.subtitle',
      gradientColors: [AppColors.gradientPurple, AppColors.gradientDeep],
    ),
    _OnboardSlide(
      icon: AppIcons.ai,
      title: 'onboarding.slides.ai.title',
      subtitle: 'onboarding.slides.ai.subtitle',
      gradientColors: [AppColors.gradientDeep, AppColors.surfaceDeep],
    ),
    // Virtual slide for Paywall
    _OnboardSlide(
      icon: Icons.star,
      title: 'XINGCAM PRO',
      subtitle: '',
      gradientColors: [AppColors.gold, AppColors.background],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() async {
    HapticFeedback.lightImpact();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Paywall Action
      await context.read<AiCreditService>().setProStatus(true);
      _getStarted();
    }
  }

  void _getStarted() {
    HapticFeedback.mediumImpact();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isPaywall = _currentPage == _slides.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surfaceDeep,
        body: Stack(
          children: [
            // Animated page view
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) {
                if (i == _slides.length - 1) {
                  return SubscriptionPaywallWidget(onPremiumStarted: _getStarted);
                }
                return _OnboardPage(slide: _slides[i]);
              },
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Column(
                    children: [
                      // Dot indicators
                      if (!isPaywall)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _currentPage ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _currentPage
                                    ? AppColors.primary
                                    : AppColors.surfaceLight,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: isPaywall ? 0 : 32),

                      // Next / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: isPaywall 
                                  ? [AppColors.gold, const Color(0xFFD4AF37)]
                                  : [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isPaywall ? AppColors.gold : AppColors.primary).withValues(alpha: 0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: isPaywall ? Colors.black : AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isPaywall 
                                  ? 'DÙNG THỬ 3 NGÀY MIỄN PHÍ'
                                  : (_currentPage == _slides.length - 2
                                    ? 'TIẾP TỤC'
                                    : context.tr('onboarding.next')),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Skip / Close button
                      if (!isPaywall)
                        TextButton(
                          onPressed: _getStarted,
                          child: Text(
                            context.tr('onboarding.skip'),
                            style: const TextStyle(fontFamily: 'Outfit', 
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                         TextButton(
                          onPressed: _getStarted,
                          child: const Text(
                            'Để sau, tiếp tục với bản giới hạn',
                            style: TextStyle(fontFamily: 'Outfit', 
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
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

class _OnboardSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  const _OnboardSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardSlide slide;
  const _OnboardPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            slide.gradientColors[0],
            slide.gradientColors[0].withValues(alpha: 0.18),
            AppColors.background,
          ],
          stops: const [0.0, 0.38, 0.72],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing icon or Magic Preview
          if (slide.title == 'onboarding.slides.filters.title')
            _MagicPreviewViewfinder()
          else
            // Glowing icon — dual halo
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.gradientColors[0].withValues(alpha: 0.55),
                    slide.gradientColors[0].withValues(alpha: 0.18),
                    slide.gradientColors[0].withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: slide.title == 'onboarding.slides.retro.title'
                  ? const _SovereignDeclaration()
                  : Icon(
                      slide.icon,
                      size: 72,
                      color: AppColors.textPrimary,
                    ),
            ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                  Text(
                    context.tr(slide.title),
                    style: const TextStyle(fontFamily: 'Outfit', 
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                Text(
                  context.tr(slide.subtitle),
                  style: const TextStyle(fontFamily: 'Outfit', 
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.6,
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

class _MagicPreviewViewfinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return const SizedBox.shrink();
  }
}

class _SovereignDeclaration extends StatefulWidget {
  const _SovereignDeclaration();
  @override
  State<_SovereignDeclaration> createState() => _SovereignDeclarationState();
}

class _SovereignDeclarationState extends State<_SovereignDeclaration> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _blink = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat();
    _ctrl.addListener(() { if (mounted) setState(() => _blink = _ctrl.value > 0.5); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(AppIcons.lock, color: AppColors.gold, size: 40),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SOVEREIGN MODE', style: TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            if (_blink) Container(width: 6, height: 10, color: AppColors.gold),
          ],
        ),
      ],
    );
  }
}
