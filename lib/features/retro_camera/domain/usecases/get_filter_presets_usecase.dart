import 'package:dartz/dartz.dart';
import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:injectable/injectable.dart';
import '../entities/filter_preset.dart';
import '../repositories/retro_camera_repository.dart';

@injectable
class GetFilterPresetsUseCase implements UseCase<List<FilterPreset>, NoParams> {
  final RetroCameraRepository repository;

  GetFilterPresetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FilterPreset>>> call(NoParams params) async {
    return await repository.getFilterPresets();
  }
}
