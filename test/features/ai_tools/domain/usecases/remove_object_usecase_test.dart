import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/features/ai_tools/domain/entities/editable_photo.dart';
import 'package:xingcam/features/ai_tools/domain/entities/inpaint_result.dart';
import 'package:xingcam/features/ai_tools/domain/entities/removal_mask.dart';
import 'package:xingcam/features/ai_tools/domain/repositories/ai_tools_repository.dart';
import 'package:xingcam/features/ai_tools/domain/usecases/remove_object_usecase.dart';

import 'remove_object_usecase_test.mocks.dart';

@GenerateMocks([AiToolsRepository])
void main() {
  late RemoveObjectUseCase useCase;
  late MockAiToolsRepository mockRepository;

  setUp(() {
    mockRepository = MockAiToolsRepository();
    useCase = RemoveObjectUseCase(mockRepository);
  });

  const tImage = EditablePhoto(
    originalPath: '/test/image.jpg',
    width: 1920,
    height: 1080,
  );

  const tMask = RemovalMask(
    maskPath: '/test/mask.png',
    brushSize: 24.0,
  );

  final tResult = InpaintResult(
    resultImagePath: '/test/result.png',
    processedAt: DateTime(2026, 5, 29),
  );

  final tParams = RemoveObjectParams(image: tImage, mask: tMask);

  test('should call repository.removeObject with correct params', () async {
    // arrange
    when(mockRepository.removeObject(image: tImage, mask: tMask))
        .thenAnswer((_) async => Right(tResult));

    // act
    final result = await useCase(tParams);

    // assert
    expect(result, Right(tResult));
    verify(mockRepository.removeObject(image: tImage, mask: tMask)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return NetworkFailure when there is no internet', () async {
    // arrange
    when(mockRepository.removeObject(image: tImage, mask: tMask)).thenAnswer(
        (_) async => const Left(NetworkFailure('No internet connection')));

    // act
    final result = await useCase(tParams);

    // assert
    expect(result, const Left(NetworkFailure('No internet connection')));
  });

  test('should return ServerFailure on API error', () async {
    // arrange
    when(mockRepository.removeObject(image: tImage, mask: tMask)).thenAnswer(
        (_) async => const Left(ServerFailure('Replicate API timeout')));

    // act
    final result = await useCase(tParams);

    // assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('RemoveObjectParams equality works correctly', () {
    final params1 = RemoveObjectParams(image: tImage, mask: tMask);
    final params2 = RemoveObjectParams(image: tImage, mask: tMask);
    expect(params1, equals(params2));
  });
}
