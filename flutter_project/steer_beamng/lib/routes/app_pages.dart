import 'package:get/get.dart';
import 'package:steer_beamng/constants/routes_helper.dart';
import '../ui/console.dart';
import '../ui/steering_binding.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: Routes.steering,
      page: () => const Console(),
      binding: SteeringBinding(),
    ),
  ];
}
