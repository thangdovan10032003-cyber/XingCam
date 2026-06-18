import 'dart:math' as math;
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:xingcam/features/retro_camera/data/repositories/retro_camera_repository_impl.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/domain/entities/grain_settings.dart';
import 'package:xingcam/features/retro_camera/domain/entities/light_leak_settings.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';
import 'package:xingcam/core/utils/shader_lut_converter.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/recipe_repository.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/capture_photo_usecase.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/get_filter_presets_usecase.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/retro_camera_repository.dart';
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Initialization Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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

      // Load Professional 3D LUT Shader (Phase 92)
      _shaderProgram ??= await ui.FragmentProgram.fromAsset('assets/shaders/lut_engine.frag');

      // Load presets
      final presetsResult = await _getFilterPresetsUseCase!(const NoParams());
      final recipesRes = await _recipeRepository!.getAllRecipes();
      
      presetsResult.fold(
        (failure) => emit(RetroCameraError(failure.message)),
        (presets) async {
          // Pre-generate LUT textures for current presets
          for (final p in presets) {
            if (p.lutAssetPath.isNotEmpty && !_lutImages.containsKey(p.id)) {
              try {
                final content = await rootBundle.loadString(p.lutAssetPath);
                final lut = null /* Lut3D.fromCubeFile(content) */;
                final img = await ShaderLutConverter.createLutImage(lut);
                _lutImages[p.id] = img;
              } catch (_) {}
            }
          }

          // Load Identity LUT as fallback (Phase 92)
          if (!_lutImages.containsKey('identity')) {
            final data = await rootBundle.load('assets/luts/identity.png');
            final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
            final frame = await codec.getNextFrame();
            _lutImages['identity'] = frame.image;
          }

          emit(RetroCameraReady(
            presets: presets,
            selectedPreset: presets.first,
            grainSettings: const GrainSettings(),
            shader: _shaderProgram?.fragmentShader(),
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Filter selection Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  void selectFilter(FilterPreset preset) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith(
        selectedPreset: preset,
        lutImage: _lutImages[preset.id],
      ));
    }
  }

  void selectSecondaryFilter(FilterPreset preset) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith(
        //lutBImage: _lutImages[preset.id],
      ));
    }
  }

  void updateInterpolation(double value) {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      emit(ready.copyWith()); // lutInterpolation: value (deferred)
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ AI Smart Preset (Phase 25) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  void toggleAutoMode() {
    if (state is RetroCameraReady) {
      final ready = state as RetroCameraReady;
      // In a real app, this would start a periodic analysis of frames
      _performSmartAnalysis();
    }
  }

  Future<void> _performSmartAnalysis() async {
    if (state is! RetroCameraReady) return;
    final ready = state as RetroCameraReady;
    
    // Simulating AI analysis of the current frame
    // In production, we would sample the CameraImage pixels
    final brightness = math.Random().nextDouble(); // Placeholder for actual luminance check
    
    FilterPreset suggested;
    if (brightness > 0.7) {
      // Sunny/Bright -> Vivid
      suggested = ready.presets.firstWhere((p) => p.id == 'vibrant_chrome', orElse: () => ready.presets.first);
    } else if (brightness < 0.3) {
      // Dim/Night -> Moody
      suggested = ready.presets.firstWhere((p) => p.id == 'cool_fade', orElse: () => ready.presets.first);
    } else {
      // Natural
      suggested = ready.presets.firstWhere((p) => p.id == 'classic_film', orElse: () => ready.presets.first);
    }
    
    if (suggested.id != ready.selectedPreset.id) {
       selectFilter(suggested);
       HapticsUtility.dialClick();
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Aspect Ratio & Borders Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  // Ã¢â€â‚¬Ã¢â€â‚¬ Grain settings Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  void updateGrain(GrainSettings settings) {
    final current = state;
    if (current is RetroCameraReady) {
      emit(current.copyWith(grainSettings: settings));
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Light leak Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Camera Zoom & Aspect Ratio Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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
      // Ignore zoom errors in preview
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Recipe Actions Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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
        id: '', // Will be set by Isar
        name: name,
        filter: ready.selectedPreset,
        grainIntensity: ready.grainSettings.intensity,
        borderType: ready.selectedBorder,
      );
      
      final res = await _recipeRepository!.saveRecipe(recipe);
      res.fold(
        (l) => null,
        (r) => loadRecipes(), // Reload
      );
    }
  }

  Future<void> updateRecipe(FilmRecipe recipe) async {
    if (state is RetroCameraReady) {
      final res = await _recipeRepository!.saveRecipe(recipe);
      res.fold(
        (l) => null,
        (r) => loadRecipes(), // Reload and emit new state
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
      // Re-load LUT for the new preset
      selectFilter(recipe.filter);
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Capture Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

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
          // Save to Camera Roll using gal
          try {
            await Gal.putImage(photo.path, album: 'XingCam');
          } catch (e) {
            // Log but don't fail the whole capture if gallery save fails
          }
          emit(RetroCameraCaptured(photo));
        },
      );
    } on CameraException catch (e) {
      emit(current.copyWith(isTakingPhoto: false));
      emit(RetroCameraError(e.description ?? 'Unknown camera error'));
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Camera lifecycle Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  
  void pauseCamera() {
    _cameraController?.pausePreview();
    // Also stop image stream if active
    try {
      _cameraController?.stopImageStream();
    } catch (_) {}
  }

  void resumeCamera() {
    _cameraController?.resumePreview();
    // Restart image stream if in ready state
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
      emit(current.copyWith()); // Trigger UI refresh
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



