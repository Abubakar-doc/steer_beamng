import 'package:get/get.dart';
import 'package:steer_beamng/constants/routes_helper.dart';
import 'package:steer_beamng/services/app_version_manager.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    handleSplashNavigation();
  }

  Future<void> handleSplashNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offNamed(Routes.console);
    await AppVersionManager.checkForForcedUpdate();
    return;
  }
}
