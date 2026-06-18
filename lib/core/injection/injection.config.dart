// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i17;

import '../../features/ai_tools/data/repositories/ai_tools_repository_impl.dart'
    as _i4;
import '../../features/ai_tools/domain/repositories/ai_tools_repository.dart'
    as _i3;
import '../../features/ai_tools/domain/usecases/remove_object_usecase.dart'
    as _i18;
import '../../features/gallery/presentation/bloc/gallery_cubit.dart' as _i9;
import '../../features/retro_camera/data/repositories/recipe_repository_impl.dart'
    as _i16;
import '../../features/retro_camera/domain/repositories/recipe_repository.dart'
    as _i15;
import '../../features/retro_camera/domain/repositories/retro_camera_repository.dart'
    as _i7;
import '../../features/retro_camera/domain/usecases/capture_photo_usecase.dart'
    as _i6;
import '../../features/retro_camera/domain/usecases/get_filter_presets_usecase.dart'
    as _i10;
import '../../features/retro_camera/presentation/bloc/retro_camera_cubit.dart'
    as _i19;
import '../database/isar_service.dart' as _i11;
import '../services/bionic_sharp_service.dart' as _i5;
import '../services/cvd_accessibility_service.dart' as _i8;
import '../services/nearby_p2p_service.dart' as _i12;
import '../services/on_device_ai_service.dart' as _i13;
import '../services/proxy_storage_service.dart' as _i14;
import '../services/shutter_haptics_service.dart' as _i20;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.AiToolsRepository>(() => _i4.AiToolsRepositoryImpl());
    gh.lazySingleton<_i5.BionicSharpService>(() => _i5.BionicSharpService());
    gh.factory<_i6.CapturePhotoUseCase>(
        () => _i6.CapturePhotoUseCase(gh<_i7.RetroCameraRepository>()));
    gh.lazySingleton<_i8.CvdAccessibilityService>(
        () => _i8.CvdAccessibilityService());
    gh.factory<_i9.GalleryCubit>(
        () => _i9.GalleryCubit(gh<_i7.RetroCameraRepository>()));
    gh.factory<_i10.GetFilterPresetsUseCase>(
        () => _i10.GetFilterPresetsUseCase(gh<_i7.RetroCameraRepository>()));
    gh.singleton<_i11.IsarService>(() => _i11.IsarService());
    gh.lazySingleton<_i12.NearbyP2PService>(() => _i12.NearbyP2PService());
    gh.lazySingleton<_i13.OnDeviceAiService>(() => _i13.OnDeviceAiService());
    gh.lazySingleton<_i14.ProxyStorageService>(
        () => _i14.ProxyStorageService());
    gh.lazySingleton<_i15.RecipeRepository>(() => _i16.RecipeRepositoryImpl(
          gh<_i17.Isar>(),
          gh<_i7.RetroCameraRepository>(),
        ));
    gh.factory<_i18.RemoveObjectUseCase>(
        () => _i18.RemoveObjectUseCase(gh<_i3.AiToolsRepository>()));
    gh.factory<_i19.RetroCameraCubit>(() => _i19.RetroCameraCubit(
          gh<_i10.GetFilterPresetsUseCase>(),
          gh<_i6.CapturePhotoUseCase>(),
          gh<_i15.RecipeRepository>(),
        ));
    gh.lazySingleton<_i20.ShutterHapticsService>(
        () => _i20.ShutterHapticsService());
    return this;
  }
}
