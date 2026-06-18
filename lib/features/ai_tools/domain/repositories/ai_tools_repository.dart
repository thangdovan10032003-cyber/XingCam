import 'package:dartz/dartz.dart';
import 'package:xingcam/core/error/failures.dart';
import '../entities/editable_photo.dart';
import '../entities/removal_mask.dart';
import '../entities/inpaint_result.dart';

abstract class AiToolsRepository {
  Future<Either<Failure, InpaintResult>> removeObject({
    required EditablePhoto image,
    required RemovalMask mask,
  });
}
