import 'package:get/get.dart';
import 'package:steer_beamng/bindings/settings_binding.dart';
import 'package:steer_beamng/constants/routes_helper.dart';
import 'package:steer_beamng/ui/settings_view.dart';
import '../ui/console_view.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: Routes.steering,
      page: () => const ConsoleView(),
    ),GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),

  ];
}
