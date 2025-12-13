import 'package:get/get.dart';
import 'package:steer_beamng/bindings/console_binding.dart';
import 'package:steer_beamng/bindings/settings_binding.dart';
import 'package:steer_beamng/bindings/splash_binding.dart';
import 'package:steer_beamng/constants/routes_helper.dart';
import 'package:steer_beamng/constants/theme_helper.dart';
import 'package:steer_beamng/ui/settings_view.dart';
import 'package:steer_beamng/ui/splash_view.dart';
import '../ui/console_view.dart';

class AppPages {
  static const transitionDuration = AppTheme.defaultViewTransitionDuration;
  static final routes = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: transitionDuration),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.console,
      page: () => const ConsoleView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: transitionDuration),
      binding: ConsoleBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: transitionDuration),
      binding: SettingsBinding(),
    ),
  ];
}
