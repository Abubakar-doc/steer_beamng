import 'package:get/get.dart';
import 'package:steer_beamng/services/pedal_service.dart';
import 'package:steer_beamng/services/steering_service.dart';
import 'package:steer_beamng/services/tcp_service.dart';
import 'package:steer_beamng/services/gearbox_service.dart';

class ConsoleController extends GetxController {
  late TcpService tcp;

  final pedal = 0.0.obs;

  late SteeringService steering;
  late PedalService pedalService;
  late GearboxService gearbox;

  final angles = [270.0, 360.0, 450.0, 540.0, 720.0, 900.0];
  final selectedAngle = 450.0.obs;

  // VALID gear counts (5 = 1–5 + R)
  final gearOptions = [5, 6, 7, 8];

  // DEFAULT gearbox is 5 + R
  final selectedGearCount = 5.obs;

  @override
  void onInit() {
    super.onInit();

    tcp = TcpService(onData: _processServerLine);

    steering = SteeringService(sendSteer, () {})
      ..maxAngle.value = selectedAngle.value;

    pedalService = PedalService(pedal, sendPedals, () {});

    gearbox = GearboxService(sendGear)
      ..setAvailableGears(selectedGearCount.value);

    tcp.connect();
  }

  @override
  void onClose() {
    tcp.dispose();
    super.onClose();
  }

  void _processServerLine(String line) {}

  // Send steering to server
  void sendSteer(double v) => tcp.send(v.toStringAsFixed(6));

  // Send pedals to server
  void sendPedals(double thr, double brk) {
    tcp.send("THR:${thr.toStringAsFixed(3)}");
    tcp.send("BRK:${brk.toStringAsFixed(3)}");
  }

  // Send gear to server
  void sendGear(int g) {
    tcp.send("GEAR:$g");
  }

  void connectVJoy() => tcp.connect();

  void setSteeringAngle(double a) {
    selectedAngle.value = a;
    steering.maxAngle.value = a;
  }

  // Set how many forward gears exist (Reverse always included)
  void setGearCount(int g) {
    selectedGearCount.value = g;

    // EX: if g = 5 → gearbox supports 1,2,3,4,5 and R
    gearbox.setAvailableGears(g);
  }
}
