import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';

class ArProjectorScreen extends StatefulWidget {
  final List<String> imagePaths;
  const ArProjectorScreen({super.key, required this.imagePaths});

  @override
  State<ArProjectorScreen> createState() => _ArProjectorScreenState();
}

class _ArProjectorScreenState extends State<ArProjectorScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isAutoPlay = false;
  Timer? _autoPlayTimer;
  double _flickerOpacity = 0.0;
  late AnimationController _flickerController;
  Color _ambientColor = AppColors.background;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
      setState(() {
        _flickerOpacity = math.Random().nextDouble() * 0.05;
      });
    });
    _flickerController.repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHelp());
  }

  void _showHelp() {
    TutorialOverlay.show(
      context,
      title: 'Slide Exhibition',
      description: 'Relive your memories with a vintage slide projector. Use the controls to Skip or enable Auto-Play for an immersive flickery show.',
      icon: AppIcons.camera,
    );
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlay = !_isAutoPlay;
      if (_isAutoPlay) {
        _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
          if (_currentIndex < widget.imagePaths.length - 1) {
            _pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
          } else {
            _pageController.animateToPage(0, duration: const Duration(milliseconds: 1200), curve: Curves.slowMiddle);
          }
        });
      } else {
        _autoPlayTimer?.cancel();
      }
    });
    HapticsUtility.dialClick();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ambientColor.withValues(alpha: 0.9), // Sovereign Ambient Bleed
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Projected Image Center
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) {
               setState(() {
                 _currentIndex = i;
                 _ambientColor = AppColors.background;
               });
               // Kodak "Click-Thunk" Sequence (Phase 199)
               HapticsUtility.heavyImpact();
               Future.delayed(const Duration(milliseconds: 100), () => HapticsUtility.lightImpact());
            },
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 100,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Perspective Transformation (Phase 199)
                      Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspective
                          ..rotateY(0.02) // Slight tilt
                          ..rotateX(0.01),
                        alignment: FractionalOffset.center,
                        child: Image.file(File(widget.imagePaths[index]), fit: BoxFit.contain),
                      ),
                      // Projector "Overlay" Effects
                      Container(color: AppColors.textPrimary.withValues(alpha: _flickerOpacity)), // Flicker
                      _buildProjectorDustOverlay(),
                    ],
                  ),
                ),
              );
            },
          ),

          // Projector Frame / Lens Vignette
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.transparent, AppColors.background.withValues(alpha: 0.9)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.back, color: AppColors.textSecondary),
                    onPressed: () => context.pop(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('gallery.projector_title'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.textPrimary, fontSize: 24, letterSpacing: 2)),
                      Text('${_currentIndex + 1} / ${widget.imagePaths.length}', style: const TextStyle(fontFamily: 'VT323', color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                  _isAutoPlay ? const Icon(AppIcons.sync, color: AppColors.primary) : const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProjectorBtn(
                  icon: AppIcons.skipBack, 
                  onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease)
                ),
                const SizedBox(width: 24),
                _ProjectorBtn(
                  icon: _isAutoPlay ? AppIcons.pause : AppIcons.play,
                  size: 72,
                  color: AppColors.primary,
                  onTap: _toggleAutoPlay,
                ),
                const SizedBox(width: 24),
                _ProjectorBtn(
                  icon: AppIcons.skipForward,
                  onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectorDustOverlay() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: CustomPaint(painter: _DustPainter()),
      ),
    );
  }
}

class _ProjectorBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  const _ProjectorBtn({required this.icon, required this.onTap, this.size = 56, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.2) ?? AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: color ?? AppColors.border, width: 2),
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: size * 0.5),
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary;
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.5,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



