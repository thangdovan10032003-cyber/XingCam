import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/core/usecases/usecase.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/retro_camera_repository.dart';
import 'package:xingcam/features/retro_camera/domain/usecases/get_filter_presets_usecase.dart';

import 'get_filter_presets_usecase_test.mocks.dart';

@GenerateMocks([RetroCameraRepository])
void main() {
  late GetFilterPresetsUseCase useCase;
  late MockRetroCameraRepository mockRepository;

  setUp(() {
    mockRepository = MockRetroCameraRepository();
    useCase = GetFilterPresetsUseCase(mockRepository);
  });

  const tPresets = [
    FilterPreset(
      id: 'none',
      name: 'Original',
      lutAssetPath: '',
    ),
    FilterPreset(
      id: 'fuji_superia',
      name: 'Fuji Superia',
      lutAssetPath: 'assets/luts/fuji_superia.cube',
    ),
  ];

  test('should return a list of FilterPresets from the repository', () async {
    // arrange
    when(mockRepository.getFilterPresets())
        .thenAnswer((_) async => const Right(tPresets));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Right(tPresets));
    verify(mockRepository.getFilterPresets()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return exactly the presets returned by the repository', () async {
    // arrange
    when(mockRepository.getFilterPresets())
        .thenAnswer((_) async => const Right(tPresets));

    // act
    final result = await useCase(const NoParams());

    // assert
    result.fold(
      (failure) => fail('Expected Right but got Left: $failure'),
      (presets) {
        expect(presets.length, 2);
        expect(presets.first.id, 'none');
        expect(presets.last.id, 'fuji_superia');
      },
    );
  });

  test('should delegate errors straight from the repository', () async {
    // arrange
    when(mockRepository.getFilterPresets()).thenAnswer(
        (_) async => const Left(StorageFailure('Presets load failed')));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result.isLeft(), true);
  });
}
