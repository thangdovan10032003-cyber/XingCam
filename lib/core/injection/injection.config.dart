// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i5;

import '../../features/ai_tools/data/repositories/ai_tools_repository_impl.dart'
    as _i28;
import '../../features/ai_tools/domain/repositories/ai_tools_repository.dart'
    as _i27;
import '../../features/ai_tools/domain/usecases/remove_object_usecase.dart'
    as _i31;
import '../../features/gallery/presentation/bloc/gallery_cubit.dart' as _i29;
import '../../features/retro_camera/data/providers/native_camera_provider.dart'
    as _i11;
import '../../features/retro_camera/data/repositories/recipe_repository_impl.dart'
    as _i30;
import '../../features/retro_camera/data/repositories/retro_camera_repository_impl.dart'
    as _i22;
import '../../features/retro_camera/domain/repositories/recipe_repository.dart'
    as _i20;
import '../../features/retro_camera/domain/repositories/retro_camera_repository.dart'
    as _i21;
import '../../features/retro_camera/domain/usecases/capture_photo_usecase.dart'
    as _i19;
import '../../features/retro_camera/domain/usecases/get_filter_presets_usecase.dart'
    as _i18;
import '../../features/retro_camera/presentation/bloc/retro_camera_cubit.dart'
    as _i17;
import '../database/isar_service.dart' as _i9;
import '../engine/rust_core_engine.dart' as _i23;
import '../services/bionic_sharp_service.dart' as _i3;
import '../services/cloud_backup_service.dart' as _i4;
import '../services/crypto_c2pa_service.dart' as _i6;
import '../services/cvd_accessibility_service.dart' as _i7;
import '../services/edge_ai_service.dart' as _i8;
import '../services/local_llm_router.dart' as _i10;
import '../services/nearby_p2p_service.dart' as _i12;
import '../services/on_device_ai_service.dart' as _i13;
import '../services/p2p_mesh_network_service.dart' as _i14;
import '../services/proxy_storage_service.dart' as _i15;
import '../services/remote_config_service.dart' as _i16;
import '../services/shutter_haptics_service.dart' as _i24;
import '../services/subscription_service.dart' as _i25;
import '../services/thermal_management_service.dart' as _i26;

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
    gh.lazySingleton<_i3.BionicSharpService>(() => _i3.BionicSharpService());
    gh.lazySingleton<_i4.CloudBackupService>(
        () => _i4.CloudBackupService(gh<_i5.Isar>()));
    gh.lazySingleton<_i6.CryptoC2paService>(() => _i6.CryptoC2paService());
    gh.lazySingleton<_i7.CvdAccessibilityService>(
        () => _i7.CvdAccessibilityService());
    gh.lazySingleton<_i8.EdgeAiService>(() => _i8.EdgeAiService());
    gh.singleton<_i9.IsarService>(() => _i9.IsarService());
    gh.lazySingleton<_i10.LocalLlmRouterService>(
        () => _i10.LocalLlmRouterService());
    gh.lazySingleton<_i11.NativeCameraProvider>(
        () => _i11.NativeCameraProvider());
    gh.lazySingleton<_i12.NearbyP2PService>(() => _i12.NearbyP2PService());
    gh.lazySingleton<_i13.OnDeviceAiService>(() => _i13.OnDeviceAiService());
    gh.lazySingleton<_i14.P2PMeshNetworkService>(
        () => _i14.P2PMeshNetworkService());
    gh.lazySingleton<_i15.ProxyStorageService>(
        () => _i15.ProxyStorageService());
    gh.lazySingleton<_i16.RemoteConfigService>(
        () => _i16.RemoteConfigService());
    gh.factory<_i17.RetroCameraCubit>(() => _i17.RetroCameraCubit(
          gh<_i18.GetFilterPresetsUseCase>(),
          gh<_i19.CapturePhotoUseCase>(),
          gh<_i20.RecipeRepository>(),
        ));
    gh.lazySingleton<_i21.RetroCameraRepository>(
        () => _i22.RetroCameraRepositoryImpl(gh<_i9.IsarService>()));
    gh.lazySingleton<_i23.RustCoreEngine>(() => _i23.RustCoreEngine());
    gh.lazySingleton<_i24.ShutterHapticsService>(
        () => _i24.ShutterHapticsService());
    gh.lazySingleton<_i25.SubscriptionService>(
        () => _i25.SubscriptionService());
    gh.lazySingleton<_i26.ThermalManagementService>(
        () => _i26.ThermalManagementService());
    gh.factory<_i27.AiToolsRepository>(
        () => _i28.AiToolsRepositoryImpl(gh<_i23.RustCoreEngine>()));
    gh.factory<_i19.CapturePhotoUseCase>(
        () => _i19.CapturePhotoUseCase(gh<_i21.RetroCameraRepository>()));
    gh.factory<_i29.GalleryCubit>(
        () => _i29.GalleryCubit(gh<_i21.RetroCameraRepository>()));
    gh.factory<_i18.GetFilterPresetsUseCase>(
        () => _i18.GetFilterPresetsUseCase(gh<_i21.RetroCameraRepository>()));
    gh.lazySingleton<_i20.RecipeRepository>(() => _i30.RecipeRepositoryImpl(
          gh<_i5.Isar>(),
          gh<_i21.RetroCameraRepository>(),
        ));
    gh.factory<_i31.RemoveObjectUseCase>(
        () => _i31.RemoveObjectUseCase(gh<_i27.AiToolsRepository>()));
    return this;
  }
}
