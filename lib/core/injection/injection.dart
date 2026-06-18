import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';
import 'package:isar/isar.dart';
import 'package:xingcam/core/services/edge_ai_service.dart';
import 'package:xingcam/core/services/cloud_backup_service.dart';
import 'package:xingcam/core/services/crypto_c2pa_service.dart';
import 'package:xingcam/core/services/subscription_service.dart';
import 'package:xingcam/core/services/local_llm_router.dart';
import 'package:xingcam/core/services/thermal_management_service.dart';
import 'package:xingcam/core/services/p2p_mesh_network_service.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() {
  getIt.init();
  if (!getIt.isRegistered<EdgeAiService>()) {
    getIt.registerLazySingleton<EdgeAiService>(() => EdgeAiService());
  }
  if (!getIt.isRegistered<CloudBackupService>()) {
    getIt.registerLazySingleton<CloudBackupService>(() => CloudBackupService(getIt<Isar>()));
  }
  if (!getIt.isRegistered<CryptoC2paService>()) {
    getIt.registerLazySingleton<CryptoC2paService>(() => CryptoC2paService());
  }
  if (!getIt.isRegistered<SubscriptionService>()) {
    getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  }
  if (!getIt.isRegistered<LocalLlmRouterService>()) {
    getIt.registerLazySingleton<LocalLlmRouterService>(() => LocalLlmRouterService());
  }
  if (!getIt.isRegistered<ThermalManagementService>()) {
    getIt.registerLazySingleton<ThermalManagementService>(() => ThermalManagementService());
  }
  if (!getIt.isRegistered<P2PMeshNetworkService>()) {
    getIt.registerLazySingleton<P2PMeshNetworkService>(() => P2PMeshNetworkService());
  }
}
