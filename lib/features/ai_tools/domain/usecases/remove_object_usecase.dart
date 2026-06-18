import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:injectable/injectable.dart';
import '../entities/editable_photo.dart';
import '../entities/removal_mask.dart';
import '../entities/inpaint_result.dart';
import '../repositories/ai_tools_repository.dart';

@injectable
class RemoveObjectUseCase
    implements UseCase<InpaintResult, RemoveObjectParams> {
  final AiToolsRepository repository;

  RemoveObjectUseCase(this.repository);

  @override
  Future<Either<Failure, InpaintResult>> call(RemoveObjectParams params) async {
    return await repository.removeObject(
      image: params.image,
      mask: params.mask,
    );
  }
}

class RemoveObjectParams extends Equatable {
  final EditablePhoto image;
  final RemovalMask mask;

  const RemoveObjectParams({required this.image, required this.mask});

  @override
  List<Object?> get props => [image, mask];
}
