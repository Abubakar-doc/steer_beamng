import 'package:get/get.dart';
import '../controllers/steering_controller.dart';

class SteeringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SteeringController>(() => SteeringController());
  }
}
