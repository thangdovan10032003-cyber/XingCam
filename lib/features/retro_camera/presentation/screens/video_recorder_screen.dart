import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/widgets/app_header.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_cubit.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_state.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/gpu_lut_preview.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}
class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;
  bool _beautyEnabled = false;
  double _smoothLevel = 0.5;
  double _brightLevel = 0.5;
  bool _slimEnabled = false;
  bool _isHUDVisible = true; // Phase 113: HUD Visibility Toggle

  @override
  void initState() {
    super.initState();
    context.read<RetroCameraCubit>().init();
  }

  void _toggleHUD() {
    setState(() => _isHUDVisible = !_isHUDVisible);
    HapticsUtility.dialClick();
  }

  void _startTimer() {
    _recordSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _toggleRecording() {
    final cubit = context.read<RetroCameraCubit>();
    if (_isRecording) {
      _stopTimer();
    } else {
      _startTimer();
    }
    HapticsUtility.dialClick();
    setState(() => _isRecording = !_isRecording);
  }

  void _toggleBeauty() {
    setState(() => _beautyEnabled = !_beautyEnabled);
    HapticsUtility.dialClick();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetroCameraCubit, RetroCameraState>(
      builder: (context, state) {
        if (state is! RetroCameraReady) {
          return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CircularProgressIndicator()));
        }

        final controller = context.read<RetroCameraCubit>().cameraController;
        if (controller == null || !controller.value.isInitialized) {
          return Scaffold(backgroundColor: AppColors.background);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Viewfinder + GPU Shader
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: state.shader != null && state.lutImage != null
                      ? GpuLutPreview(
                          shader: state.shader!,
                          lutImage: state.lutImage!,
                          lutBImage: state.lutBImage,
                          interpolation: state.lutInterpolation,
                          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width / controller.value.aspectRatio),
                          child: CameraPreview(controller),
                        )
                      : CameraPreview(controller),
                ),
              ),

          // VHS Overlay Simulation
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _isHUDVisible ? 1.0 : (_isRecording ? 0.0 : 0.2), // Dim or hide in clean mode
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textPrimary.withOpacity(0.05), width: 20),
                ),
                child: Stack(
                  children: [
                     // TOP Indicators
                     Positioned(
                       top: 40,
                       left: 20,
                       child: Text(context.tr('video_recorder.play'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.textPrimary, fontSize: 24)),
                     ),
                     Positioned(
                       top: 40,
                       right: 20,
                       child: Text(context.tr('video_recorder.sp'), style: const TextStyle(fontFamily: 'VT323', color: AppColors.textPrimary, fontSize: 24)),
                     ),
                     // BOTTOM Indicators
                     Positioned(
                       bottom: 40,
                       left: 20,
                       child: Text(
                         '${DateTime.now().month.toString().padLeft(2, '0')} ${_recordSeconds ~/ 60}:${(_recordSeconds % 60).toString().padLeft(2, '0')}:${_recordSeconds % 10}0', 
                          style: const TextStyle(fontFamily: 'VT323', color: AppColors.textPrimary, fontSize: 28)
                       ),
                     ),
                     if (_beautyEnabled)
                      Positioned(
                        top: 120,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BeautyIndicator(label: 'SMOOTH', value: _smoothLevel),
                            _BeautyIndicator(label: 'BRIGHT', value: _brightLevel),
                            if (_slimEnabled) _BeautyIndicator(label: 'SLIM', value: 1.0),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!_isRecording) ...[
                  Text(context.tr('video_recorder.transition'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.3), fontSize: 10, letterSpacing: 2)),
                  Slider(
                    value: state.lutInterpolation,
                    onChanged: (v) => context.read<RetroCameraCubit>().updateInterpolation(v),
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.textPrimary.withOpacity(0.1),
                  ),
                  const SizedBox(height: 8),
                ],
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording
                            ? AppColors.error
                            : AppColors.textPrimary.withOpacity(0.6),
                        width: 3,
                      ),
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 3,
                              )
                            ]
                          : [],
                    ),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _isRecording ? AppColors.error : AppColors.textPrimary.withOpacity(0.18),
                        shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: _isRecording ? BorderRadius.circular(10) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(AppIcons.close, color: AppColors.textPrimary, size: 32),
                    ),
                    const SizedBox(width: 20),
                    _CircularControl(
                      icon: _isHUDVisible ? AppIcons.visibility : AppIcons.visibilityOff,
                      label: 'VIEW',
                      isActive: _isHUDVisible,
                      onTap: _toggleHUD,
                    ),
                    const SizedBox(width: 20),
                    _CircularControl(
                      icon: _beautyEnabled ? AppIcons.beautify : AppIcons.sculpt,
                      label: 'BEAUTY',
                      isActive: _beautyEnabled,
                      onTap: _toggleBeauty,
                    ),
                    _CircularControl(
                      icon: AppIcons.magic,
                      label: 'TRANSITION',
                      isActive: state.lutBImage != null,
                      onTap: () {
                         // Select the next filter in the list for B-side
                         final nextIdx = (state.presets.indexOf(state.selectedPreset) + 1) % state.presets.length;
                         context.read<RetroCameraCubit>().selectSecondaryFilter(state.presets[nextIdx]);
                         HapticsUtility.dialClick();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _BeautyIndicator extends StatelessWidget {
  final String label;
  final double value;
  const _BeautyIndicator({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: ${(value * 100).toInt()}%',
        style: TextStyle(fontFamily: 'VT323', color: AppColors.accent.withOpacity(0.8), fontSize: 16),
      ),
    );
  }
}

class _CircularControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CircularControl({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.accent.withOpacity(0.15)
                  : AppColors.textPrimary.withOpacity(0.06),
              border: Border.all(
                color: isActive
                    ? AppColors.accent
                    : AppColors.textPrimary.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.accent : AppColors.textSecondary.withOpacity(0.7),
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isActive
                  ? AppColors.accent.withOpacity(0.9)
                  : AppColors.textSecondary.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
