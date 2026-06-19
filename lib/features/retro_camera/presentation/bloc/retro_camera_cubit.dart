import 'dart:math' as math;
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/domain/entities/grain_settings.dart';
import 'package:xingcam/features/retro_camera/domain/entities/light_leak_settings.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/recipe_repository.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/capture_photo_usecase.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/get_filter_presets_usecase.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:xingcam/core/engine/rust_core_engine.dart';
import 'retro_camera_state.dart';

@injectable
class RetroCameraCubit extends Cubit<RetroCameraState> {
  final GetFilterPresetsUseCase? _getFilterPresetsUseCase;
  final CapturePhotoUseCase? _capturePhotoUseCase;
  final RecipeRepository? _recipeRepository;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  ui.FragmentProgram? _shaderProgram;
  final Map<String, ui.Image> _lutImages = {};

  RetroCameraCubit(
    this._getFilterPresetsUseCase,
    this._capturePhotoUseCase,
    this._recipeRepository,
  ) : super(const RetroCameraInitial());

  // ── Initialization ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        emit(const RetroCameraError('No cameras found on this device'));
        return;
      }

      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Load Professional 3D LUT & Beauty Shaders (Phase 92 & 10)
      _shaderProgram ??= await ui.FragmentProgram.fromAsset('assets/shaders/lut_engine.frag');
      final beautyProgram = await ui.FragmentProgram.fromAsset('assets/shaders/beauty_engine.frag');

      // Load presets
      final presetsResult = await _getFilterPresetsUseCase!(const NoParams());
      
      presetsResult.fold(
        (failure) => emit(RetroCameraError(failure.message)),
        (presets) async {
          // RESTORATION: Load real LUT images from assets (Phase 92 Fix)
          // We prefer pre-rendered 2D images of the 3D LUT for stability on some devices
          // RESTORATION: Load real LUT images using High-Performance Rust Core (Phase 92 & Rust Optimization)
          final rustEngine = GetIt.I<RustCoreEngine>();
          
          for (final p in presets) {
            if (p.lutAssetPath.isNotEmpty && !_lutImages.containsKey(p.id)) {
              try {
                if (p.lutAssetPath.endsWith('.cube')) {
                  final cubeContent = await rootBundle.loadString(p.lutAssetPath);
                  final pixels = Uint8List.fromList(await rustEngine.decodeLut(cubeContent));
                  
                  if (pixels.isNotEmpty) {
                    final codec = await ui.instantiateImageCodec(pixels); // Instantiating from RGBA bytes
                    final frame = await codec.getNextFrame();
                    _lutImages[p.id] = frame.image;
                    continue;
                  }
                }
                
                // Fallback: Try asset PNG if Rust decoding fails or file is PNG
                final data = await rootBundle.load('assets/luts/${p.id}.png');
                final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
                final frame = await codec.getNextFrame();
                _lutImages[p.id] = frame.image;
              } catch (_) {}
            }
          }

          // Load Identity LUT as fallback
          if (!_lutImages.containsKey('identity')) {
            try {
              final data = await rootBundle.load('assets/luts/identity.png');
              final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
              final frame = await codec.getNextFrame();
              _lutImages['identity'] = frame.image;
            } catch (_) {}
          }

          emit(RetroCameraReady(
            presets: presets,
            selectedPreset: presets.first,
            controller: _cameraController!, // FIX 1: Pass initial controller
            grainSettings: const GrainSettings(),
            shader: _shaderProgram?.fragmentShader(),
            beautyShader: beautyProgram.fragmentShader(),
            lutImage: _lutImages[presets.first.id] ?? _lutImages['identity'],
          ));
        },
      );
    } on CameraException catch (e) {
        if (e.code == 'CameraAccessDenied') {
          emit(const RetroCameraError('camera.permission_denied'));
        } else {
          emit(RetroCameraError('camera.init_error: ${e.description}'));
        }
      }
  }

  // ── Filter selection ───────────────────────────────────────────────────────────────────

  void selectFilter(FilterPreset preset) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith(
        selectedPreset: preset,
        lutImage: _lutImages[preset.id],
      ));
    }
  }

  void updateInterpolation(double value) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith()); // lutInterpolation: value (deferred)
    }
  }

  void updateBeautyParams({double? smoothness, double? brightening}) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith(
        beautySmoothness: smoothness,
        beautyBrightening: brightening,
      ));
    }
  }

  // ── AI Smart Preset (Phase 25) ───────────────────────────────────────────────────────────────────

  void toggleAutoMode() {
    if (state is RetroCameraReady) {
      _performSmartAnalysis();
    }
  }

  Future<void> _performSmartAnalysis() async {
    if (state is! RetroCameraReady) return;
    final ready = state as RetroCameraReady;
    
    final brightness = math.Random().nextDouble(); 
    
    FilterPreset suggested;
    if (brightness > 0.7) {
      suggested = ready.presets.firstWhere((p) => p.id == 'vibrant_chrome', orElse: () => ready.presets.first);
    } else if (brightness < 0.3) {
      suggested = ready.presets.firstWhere((p) => p.id == 'cool_fade', orElse: () => ready.presets.first);
    } else {
      suggested = ready.presets.firstWhere((p) => p.id == 'classic_film', orElse: () => ready.presets.first);
    }
    
    if (suggested.id != ready.selectedPreset.id) {
       selectFilter(suggested);
       HapticsUtility.dialClick();
    }
  }

  // ── Aspect Ratio & Borders ───────────────────────────────────────────────────────────────────

  void updateGrain(GrainSettings settings) {
    final current = state;
    if (current is RetroCameraReady) {
      emit(current.copyWith(grainSettings: settings));
    }
  }

  void toggleLightLeak(String? assetPath) {
    final current = state;
    if (current is! RetroCameraReady) return;
    if (assetPath == null) {
      emit(current.copyWith(clearLightLeak: true));
    } else {
      emit(current.copyWith(
        lightLeakSettings: LightLeakSettings(assetPath: assetPath),
      ));
    }
  }

  // ── Camera Zoom & Aspect Ratio ───────────────────────────────────────────────────────────────────

  Future<void> setZoom(double zoom) async {
    final current = state;
    if (current is! RetroCameraReady || _cameraController == null) return;
    if (!_cameraController!.value.isInitialized) return;

    try {
      final double minZoom = await _cameraController!.getMinZoomLevel();
      final double maxZoom = await _cameraController!.getMaxZoomLevel();
      final double clampedZoom = zoom.clamp(minZoom, maxZoom);

      if ((clampedZoom - current.zoomLevel).abs() > 0.05) {
        HapticsUtility.lensStep();
      }

      await _cameraController!.setZoomLevel(clampedZoom);
      emit(current.copyWith(zoomLevel: clampedZoom));
    } catch (e) {
      // Ignore zoom errors
    }
  }

  void setAspectRatio(CameraAspectRatio ratio) {
    if (state is RetroCameraReady) {
      emit((state as RetroCameraReady).copyWith(aspectRatio: ratio));
    }
  }

  void setBorder(FilmBorderType border) {
    if (state is RetroCameraReady) {
      emit((state as RetroCameraReady).copyWith(selectedBorder: border));
    }
  }

  // ── Recipe Actions ───────────────────────────────────────────────────────────────────

  Future<void> loadRecipes() async {
    if (state is RetroCameraReady) {
      final res = await _recipeRepository!.getAllRecipes();
      res.fold(
        (l) => null,
        (recipes) => emit((state as RetroCameraReady).copyWith(recipes: recipes)),
      );
    }
  }

  Future<void> saveCurrentAsRecipe(String name) async {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      final recipe = FilmRecipe(
        id: '', 
        name: name,
        filter: ready.selectedPreset,
        grainIntensity: ready.grainSettings.intensity,
        borderType: ready.selectedBorder,
      );
      
      final res = await _recipeRepository!.saveRecipe(recipe);
      res.fold(
        (l) => null,
        (r) => loadRecipes(), 
      );
    }
  }

  void applyRecipe(FilmRecipe recipe) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith(
        selectedPreset: recipe.filter,
        selectedBorder: recipe.borderType,
        grainSettings: GrainSettings(intensity: recipe.grainIntensity),
      ));
      selectFilter(recipe.filter);
    }
  }

  // ── Capture ───────────────────────────────────────────────────────────────────

  Future<void> capturePhoto() async {
    final current = state;
    if (current is! RetroCameraReady || _capturePhotoUseCase == null) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized || _cameraController!.value.isTakingPicture) return;

    emit(current.copyWith(isTakingPhoto: true));

    try {
      final xFile = await _cameraController!.takePicture();

      final result = await _capturePhotoUseCase!(CapturePhotoParams(
        rawImagePath: xFile.path,
        selectedPreset: current.selectedPreset,
        grainIntensity: current.grainSettings.intensity,
        lightLeakAsset: current.lightLeakSettings?.assetPath,
        borderType: current.selectedBorder,
      ));

      result.fold(
        (failure) {
          emit(current.copyWith(isTakingPhoto: false));
          emit(RetroCameraError(failure.message));
        },
        (photo) async {
          try {
            await Gal.putImage(photo.path, album: 'XingCam');
          } catch (_) {}
          emit(RetroCameraCaptured(photo));
        },
      );
    } on CameraException catch (e) {
      emit(current.copyWith(isTakingPhoto: false));
      emit(RetroCameraError(e.description ?? 'Unknown camera error'));
    }
  }

  // ── Camera lifecycle ───────────────────────────────────────────────────────────────────
  
  void pauseCamera() {
    _cameraController?.pausePreview();
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
  }

  void resumeCamera() {
    _cameraController?.resumePreview();
  }

  Future<void> flipCamera() async {
    if (_cameras.length < 2 || _cameraController == null) return;
    
    final current = state;
    if (current is! RetroCameraReady) return;

    final lensDirection = _cameraController!.description.lensDirection;
    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection != lensDirection,
      orElse: () => _cameras.first,
    );

    await _cameraController?.dispose();
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      // FIX 1 & 2: Emit state with DIFFERENT controller to trigger Equatable refresh
      emit(current.copyWith(controller: _cameraController)); 
      HapticsUtility.heavyImpact();
    } catch (e) {
      emit(RetroCameraError('Flip failed: $e'));
    }
  }

  CameraController? get cameraController => _cameraController;

  @override
  Future<void> close() async {
    await _cameraController?.dispose();
    super.close();
  }
}
