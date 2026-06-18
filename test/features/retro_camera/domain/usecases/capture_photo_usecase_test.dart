import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/features/retro_camera/domain/entities/captured_photo.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/retro_camera_repository.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/capture_photo_usecase.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';

import 'capture_photo_usecase_test.mocks.dart';

@GenerateMocks([RetroCameraRepository])
void main() {
  late CapturePhotoUseCase useCase;
  late MockRetroCameraRepository mockRepository;

  setUp(() {
    mockRepository = MockRetroCameraRepository();
    useCase = CapturePhotoUseCase(mockRepository);
  });

  const tPreset = FilterPreset(
    id: 'kodak_portra',
    name: 'Kodak Portra',
    lutAssetPath: 'assets/luts/kodak_portra.cube',
  );

  final tPhoto = CapturedPhoto(
    path: '/test/path/photo.jpg',
    timestamp: DateTime(2026, 5, 29),
    appliedPreset: tPreset,
  );

  const tParams = CapturePhotoParams(
    rawImagePath: '/test/raw.jpg',
    selectedPreset: tPreset,
    grainIntensity: 0.2,
    lightLeakAsset: null,
    borderType: FilmBorderType.none,
  );

  test('should call repository.capturePhoto with the correct parameters', () async {
    // arrange
    when(mockRepository.capturePhoto(
      rawImagePath: anyNamed('rawImagePath'),
      selectedPreset: anyNamed('selectedPreset'),
      grainIntensity: anyNamed('grainIntensity'),
      lightLeakAsset: anyNamed('lightLeakAsset'),
      borderType: anyNamed('borderType'),
    )).thenAnswer((_) async => Right(tPhoto));

    // act
    final result = await useCase(tParams);

    // assert
    expect(result, Right(tPhoto));
    verify(mockRepository.capturePhoto(
      rawImagePath: anyNamed('rawImagePath'),
      selectedPreset: anyNamed('selectedPreset'),
      grainIntensity: anyNamed('grainIntensity'),
      lightLeakAsset: anyNamed('lightLeakAsset'),
      borderType: anyNamed('borderType'),
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CameraFailure on camera error', () async {
    // arrange
    when(mockRepository.capturePhoto(
      rawImagePath: anyNamed('rawImagePath'),
      selectedPreset: anyNamed('selectedPreset'),
      grainIntensity: anyNamed('grainIntensity'),
      lightLeakAsset: anyNamed('lightLeakAsset'),
      borderType: anyNamed('borderType'),
    )).thenAnswer((_) async => const Left(CameraFailure('Camera not ready')));

    // act
    final result = await useCase(tParams);

    // assert
    expect(result, const Left(CameraFailure('Camera not ready')));
  });

  test('CapturePhotoParams equality works correctly', () {
    const params1 = CapturePhotoParams(
      rawImagePath: '/test/raw.jpg',
      selectedPreset: tPreset,
      grainIntensity: 0.2,
      borderType: FilmBorderType.none,
    );
    const params2 = CapturePhotoParams(
      rawImagePath: '/test/raw.jpg',
      selectedPreset: tPreset,
      grainIntensity: 0.2,
      borderType: FilmBorderType.none,
    );
    expect(params1, equals(params2));
  });
}
