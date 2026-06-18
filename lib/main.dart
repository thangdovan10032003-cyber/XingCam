import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:xingcam/core/services/ai_credit_service.dart';
import 'package:xingcam/core/services/ai_usage_service.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:xingcam/core/router/app_router.dart';
import 'package:xingcam/core/theme/app_theme.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'package:xingcam/core/services/on_device_ai_service.dart';
import 'package:xingcam/features/retro_camera/presentation/bloc/retro_camera_cubit.dart';
import 'package:xingcam/features/gallery/presentation/bloc/gallery_cubit.dart';
import 'package:xingcam/core/services/crashlytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sovereign Bootstrap: Zero telemetry and 100% offline assets confirmed.

  await EasyLocalization.ensureInitialized();

  // Initializing Sovereign Diagnostic Logging
  await CrashlyticsService.initialize();
  
  // Inject Dependencies
  configureDependencies();
  getIt.registerLazySingleton<OnDeviceAiService>(() => OnDeviceAiService());

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), Locale('vi'), Locale('es'), Locale('pt'),
        Locale('ja'), Locale('ko'), Locale('zh'), Locale('fr'),
        Locale('de'), Locale('it'), Locale('ru'), Locale('th'),
        Locale('id'), Locale('ar'), Locale('hi'), Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AiCreditService()),
          ChangeNotifierProvider(create: (_) => AiUsageService()),
        ],
        child: const XingCamApp(),
      ),
    ),
  );
}

class XingCamApp extends StatelessWidget {
  const XingCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RetroCameraCubit>(
          create: (_) => getIt<RetroCameraCubit>(),
          lazy: true,
        ),
        BlocProvider<GalleryCubit>(
          create: (_) => getIt<GalleryCubit>(),
          lazy: true,
        ),
      ],
      child: MaterialApp.router(
        title: 'XingCam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
