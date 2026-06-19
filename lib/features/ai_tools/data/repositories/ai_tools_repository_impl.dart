import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/features/ai_tools/domain/entities/editable_photo.dart';
import 'package:xingcam/features/ai_tools/domain/entities/inpaint_result.dart';
import 'package:xingcam/features/ai_tools/domain/entities/removal_mask.dart';
import 'package:xingcam/features/ai_tools/domain/repositories/ai_tools_repository.dart';
import 'package:xingcam/core/engine/rust_core_engine.dart';

@Injectable(as: AiToolsRepository)
class AiToolsRepositoryImpl implements AiToolsRepository {
  final RustCoreEngine _rustEngine;

  AiToolsRepositoryImpl(this._rustEngine);

  @override
  Future<Either<Failure, InpaintResult>> removeObject({
    required EditablePhoto image,
    required RemovalMask mask,
  }) async {
    try {
      final tempDir = (await getTemporaryDirectory()).path;
      final outPath = '$tempDir/xingcam_ai_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Call the auto-generated Rust bridge binding
      final resultPath = await _rustEngine.localInpaint(
        imagePath: image.originalPath,
        maskPath: mask.maskPath,
        outputPath: outPath,
      );

      return Right(InpaintResult(
        resultImagePath: resultPath,
        processedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ServerFailure('Sovereign Processing Error: $e'));
    }
  }
}
