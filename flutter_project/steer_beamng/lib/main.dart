import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/bindings/console_binding.dart';
import 'package:steer_beamng/controllers/theme_controller.dart';
import 'package:steer_beamng/services/remote_config_service.dart';
import 'constants/routes_helper.dart';
import 'constants/theme_helper.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:clarity_flutter/clarity_flutter.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await RemoteConfigService.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final themeController = Get.put(ThemeController());

  runApp(
    DevicePreview(
      enabled: false,
      // enabled: true,
      builder: (context) => MyApp(themeController: themeController),
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeController themeController;
  const MyApp({super.key, required this.themeController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ClarityConfig(projectId: "ul1yk50ghl");
      Clarity.initialize(context, config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Steer Beamng',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      initialBinding: ConsoleBinding(),
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
