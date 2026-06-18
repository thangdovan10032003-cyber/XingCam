import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:injectable/injectable.dart';
import '../entities/captured_photo.dart';
import '../entities/filter_preset.dart';
import '../repositories/retro_camera_repository.dart';

@injectable
class CapturePhotoUseCase
    implements UseCase<CapturedPhoto, CapturePhotoParams> {
  final RetroCameraRepository repository;

  CapturePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, CapturedPhoto>> call(CapturePhotoParams params) async {
    return await repository.capturePhoto(
      rawImagePath: params.rawImagePath,
      selectedPreset: params.selectedPreset,
      grainIntensity: params.grainIntensity,
      lightLeakAsset: params.lightLeakAsset,
      borderType: params.borderType,
    );
  }
}

class CapturePhotoParams extends Equatable {
  final String rawImagePath;
  final FilterPreset selectedPreset;
  final double grainIntensity;
  final String? lightLeakAsset;
  final FilmBorderType borderType;

  const CapturePhotoParams({
    required this.rawImagePath,
    required this.selectedPreset,
    required this.grainIntensity,
    this.lightLeakAsset,
    required this.borderType,
  });

  @override
  List<Object?> get props => [
        rawImagePath,
        selectedPreset,
        grainIntensity,
        lightLeakAsset,
        borderType,
      ];
}
