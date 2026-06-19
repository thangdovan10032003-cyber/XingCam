import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';
import 'package:xingcam/features/retro_camera/domain/entities/captured_photo.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/domain/entities/grain_settings.dart';
import 'package:xingcam/features/retro_camera/domain/entities/light_leak_settings.dart';

enum CameraAspectRatio {
  ratio4_3,
  ratio1_1,
  ratio16_9,
}

// ── State ───────────────────────────────────────────────────────────────────

sealed class RetroCameraState extends Equatable {
  const RetroCameraState();
  @override
  List<Object?> get props => [];
}

class RetroCameraInitial extends RetroCameraState {
  const RetroCameraInitial();
}

class RetroCameraReady extends RetroCameraState {
  final List<FilterPreset> presets;
  final FilterPreset selectedPreset;
  final GrainSettings grainSettings;
  final LightLeakSettings? lightLeakSettings;
  final double zoomLevel;
  final CameraAspectRatio aspectRatio;
  final bool isTakingPhoto;
  final ui.FragmentShader? shader;
  final ui.FragmentShader? beautyShader;
  final ui.Image? lutImage;
  final ui.Image? lutBImage;
  final double lutInterpolation;
  final double beautySmoothness;
  final double beautyBrightening;
  final FilmBorderType selectedBorder;
  final List<FilmRecipe> recipes;
  final CameraController controller;

  const RetroCameraReady({
    required this.presets,
    required this.selectedPreset,
    required this.controller,
    this.grainSettings = const GrainSettings(),
    this.lightLeakSettings,
    this.isTakingPhoto = false,
    this.zoomLevel = 1.0,
    this.aspectRatio = CameraAspectRatio.ratio4_3,
    this.shader,
    this.beautyShader,
    this.lutImage,
    this.lutBImage,
    this.lutInterpolation = 0.0,
    this.beautySmoothness = 0.5,
    this.beautyBrightening = 0.5,
    this.selectedBorder = FilmBorderType.none,
    this.recipes = const [],
  });

  RetroCameraReady copyWith({
    List<FilterPreset>? presets,
    FilterPreset? selectedPreset,
    CameraController? controller,
    GrainSettings? grainSettings,
    LightLeakSettings? lightLeakSettings,
    bool clearLightLeak = false,
    double? zoomLevel,
    CameraAspectRatio? aspectRatio,
    bool? isTakingPhoto,
    ui.FragmentShader? shader,
    ui.FragmentShader? beautyShader,
    ui.Image? lutImage,
    double? beautySmoothness,
    double? beautyBrightening,
    FilmBorderType? selectedBorder,
    List<FilmRecipe>? recipes,
  }) {
    return RetroCameraReady(
      presets: presets ?? this.presets,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      controller: controller ?? this.controller,
      grainSettings: grainSettings ?? this.grainSettings,
      lightLeakSettings:
          clearLightLeak ? null : (lightLeakSettings ?? this.lightLeakSettings),
      zoomLevel: zoomLevel ?? this.zoomLevel,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isTakingPhoto: isTakingPhoto ?? this.isTakingPhoto,
      shader: shader ?? this.shader,
      beautyShader: beautyShader ?? this.beautyShader,
      lutImage: lutImage ?? this.lutImage,
      lutBImage: lutBImage ?? lutBImage,
      lutInterpolation: lutInterpolation ?? lutInterpolation,
      beautySmoothness: beautySmoothness ?? this.beautySmoothness,
      beautyBrightening: beautyBrightening ?? this.beautyBrightening,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      recipes: recipes ?? this.recipes,
    );
  }

  @override
  List<Object?> get props => [
        presets,
        selectedPreset,
        controller,
        grainSettings,
        lightLeakSettings,
        zoomLevel,
        aspectRatio,
        isTakingPhoto,
        lutBImage,
        lutInterpolation,
        beautyShader,
        beautySmoothness,
        beautyBrightening,
      ];
}

class RetroCameraCapturing extends RetroCameraState {
  const RetroCameraCapturing();
}

class RetroCameraCaptured extends RetroCameraState {
  final CapturedPhoto photo;
  const RetroCameraCaptured(this.photo);
  @override
  List<Object?> get props => [photo];
}

class RetroCameraError extends RetroCameraState {
  final String message;
  const RetroCameraError(this.message);
  @override
  List<Object?> get props => [message];
}
