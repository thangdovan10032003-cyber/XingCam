import 'package:dartz/dartz.dart';
import 'package:xingcam/core/error/failures.dart';
import '../entities/captured_photo.dart';
import '../entities/filter_preset.dart';
import '../../presentation/widgets/film_border_overlay.dart';

abstract class RetroCameraRepository {
  /// Returns a hardcoded list of available filter presets.
  Future<Either<Failure, List<FilterPreset>>> getFilterPresets();

  /// Captures a photo with the given filter, grain, and light-leak settings applied.
  Future<Either<Failure, CapturedPhoto>> capturePhoto({
    required String rawImagePath,
    required FilterPreset selectedPreset,
    required double grainIntensity,
    required String? lightLeakAsset,
    required FilmBorderType borderType,
  });

  /// Returns all permanently saved photos from the device gallery store.
  Future<Either<Failure, List<CapturedPhoto>>> getCapturedPhotos();
}
