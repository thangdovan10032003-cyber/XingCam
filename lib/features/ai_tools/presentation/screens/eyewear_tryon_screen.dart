import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:easy_localization/easy_localization.dart';

class EyewearTryonScreen extends StatefulWidget {
  final String imagePath;
  const EyewearTryonScreen({super.key, required this.imagePath});

  @override
  State<EyewearTryonScreen> createState() => _EyewearTryonScreenState();
}

class _EyewearTryonScreenState extends State<EyewearTryonScreen> with SingleTickerProviderStateMixin {
  late String _currentImagePath;
  int _selectedFrame = 0;
  String? _customFramePath;
  bool _isProcessingCustom = false;
  
  Offset _position = const Offset(0.5, 0.4);
  double _scale = 1.0;
  double _shadowDepth = 0.5;
  bool _isSnapping = false;
  late AnimationController _glintController;

  final List<Map<String, dynamic>> _frames = [
    {'name': 'ai_home.tools.eyewear.frames.aviator', 'icon': AppIcons.add, 'material': 'ai_home.tools.eyewear.materials.metal'},
    {'name': 'ai_home.tools.eyewear.frames.modern', 'icon': AppIcons.style, 'material': 'ai_home.tools.eyewear.materials.acetate'},
    {'name': 'ai_home.tools.eyewear.frames.cateye', 'icon': AppIcons.visibility, 'material': 'ai_home.tools.eyewear.materials.tortoise'},
    {'name': 'ai_home.tools.eyewear.frames.wayfarer', 'icon': AppIcons.layout, 'material': 'ai_home.tools.eyewear.materials.gloss'},
    {'name': 'ai_home.tools.eyewear.frames.titanium', 'icon': AppIcons.quality, 'material': 'ai_home.tools.eyewear.materials.silver'},
  ];

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _glintController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: context.tr('ai_home.tools.eyewear.tutorial_title'),
        description: context.tr('ai_home.tools.eyewear.tutorial_desc'),
        icon: AppIcons.camera,
      );
    });
  }

  @override
  void dispose() {
    _glintController.dispose();
    super.dispose();
  }

  Future<void> _uploadCustomEyewear() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _isProcessingCustom = true);
      HapticsUtility.leverWind();
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _customFramePath = xFile.path;
          _selectedFrame = -1;
          _isProcessingCustom = false;
        });
        HapticsUtility.shutter();
      }
    }
  }

  void _aiSnap() {
    setState(() => _isSnapping = true);
    HapticsUtility.leverWind();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _position = const Offset(0.5, 0.41);
          _scale = 1.1;
          _isSnapping = false;
        });
        HapticsUtility.shutter();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: context.tr('ai_home.tools.eyewear.title'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                if (_isSnapping || _isProcessingCustom) return;
                setState(() {
                  _position += Offset(
                    details.delta.dx / MediaQuery.of(context).size.width,
                    details.delta.dy / (MediaQuery.of(context).size.height * 0.6),
                  );

                  // Magnetic Snap Logic (Phase 197)
                  // Center bridge snap at 0.5 horizontal
                  if ((_position.dx - 0.5).abs() < 0.05) {
                    final oldDx = _position.dx;
                    _position = Offset(0.5, _position.dy);
                    if ((oldDx - 0.5).abs() >= 0.01) {
                      HapticsUtility.mediumImpact();
                    }
                  }
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_currentImagePath), fit: BoxFit.contain),
                  // Dynamic Shadow
                  Align(
                    alignment: Alignment(_position.dx * 2 - 1, _position.dy * 2 - 0.98),
                    child: Opacity(
                      opacity: _shadowDepth * 0.4,
                      child: Transform.scale(
                        scale: _scale,
                        child: _selectedFrame == -1 
                          ? Image.file(File(_customFramePath!), width: 140, color: AppColors.background)
                          : Icon(_frames[_selectedFrame]['icon'] as IconData, size: 140, color: AppColors.background),
                      ),
                    ),
                  ),
                  // Wearable Eyewear
                  Align(
                    alignment: Alignment(_position.dx * 2 - 1, _position.dy * 2 - 1),
                    child: Transform.scale(
                      scale: _scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedFrame == -1 && _customFramePath != null)
                             Image.file(File(_customFramePath!), width: 140)
                          else
                             _buildPremiumFrameRenderer(),
                          
                          // Glint simulation
                          AnimatedBuilder(
                            animation: _glintController,
                            builder: (context, child) {
                              return Positioned(
                                left: 20 + (math.sin(_glintController.value * math.pi * 2) * 50),
                                child: Container(
                                  width: 15,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.transparent, AppColors.textPrimary.withValues(alpha: 0.2), AppColors.transparent],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isProcessingCustom || _isSnapping)
                    Container(
                      color: AppColors.background.withValues(alpha: 0.45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppColors.accent),
                            const SizedBox(height: 20),
                            Text(_isProcessingCustom ? context.tr('ai_home.tools.eyewear.extracting') : context.tr('ai_home.tools.eyewear.optimizing'), 
                              style: const TextStyle(fontFamily: 'VT323', color: AppColors.accent, fontSize: 18, letterSpacing: 1.5)),
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

  Widget _buildPremiumFrameRenderer() {
    final frame = _frames[_selectedFrame];
    final color = frame['material'].toString().contains('Gold') ? AppColors.gold : AppColors.textPrimary;
    return Icon(
      frame['icon'] as IconData,
      size: 140,
      color: color.withValues(alpha: 0.95),
      shadows: [
        Shadow(blurRadius: 10, color: AppColors.background.withValues(alpha: 0.8), offset: const Offset(0, 4)),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('ai_home.tools.eyewear.collection'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              if (_selectedFrame != -1) Text(context.tr(_frames[_selectedFrame]['material'] as String), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Upload Button
                GestureDetector(
                  onTap: _uploadCustomEyewear,
                  child: const Icon(AppIcons.addPhoto, color: AppColors.gold),
                ),
                if (_customFramePath != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedFrame = -1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 70,
                      decoration: BoxDecoration(
                        color: _selectedFrame == -1 ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _selectedFrame == -1 ? AppColors.accent : AppColors.transparent, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(_customFramePath!), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ...List.generate(_frames.length, (i) {
                  final isSelected = _selectedFrame == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFrame = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: 70,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSelected ? AppColors.accent : AppColors.transparent, width: 2),
                      ),
                      child: Icon(_frames[i]['icon'] as IconData, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStudioSlider(context.tr('ai_home.tools.eyewear.scale'), _scale, 0.5, 2.0),
          _buildStudioSlider(context.tr('ai_home.tools.eyewear.shadow'), _shadowDepth, 0.0, 1.0),
        ],
      ),
    );
  }

  Widget _buildStudioSlider(String label, double val, double min, double max) {
    return Row(
      children: [
        SizedBox(width: 55, child: Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10))),
        Expanded(child: Slider(
          value: val,
          min: min,
          max: max,
          activeColor: AppColors.accent,
          onChanged: (v) {
            setState(() { if(label == 'SCALE') {
              _scale = v;
            } else {
              _shadowDepth = v;
            } });
            HapticsUtility.lightFeedback();
          },
        )),
      ],
    );
  }
}
