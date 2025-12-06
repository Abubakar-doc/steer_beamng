import 'package:get/get.dart';
import 'package:steer_beamng/services/pedal_service.dart';
import 'package:steer_beamng/services/steering_service.dart';
import 'package:steer_beamng/services/udp_service.dart';
import 'package:steer_beamng/services/gearbox_service.dart';
import 'package:steer_beamng/utils/toast_utils.dart';

class ConsoleController extends GetxController {
  late UdpService udp;
  final useAutoGearbox = false.obs;
  final pedal = 0.0.obs;
  final handbrake = false.obs;

  late SteeringService steering;
  late PedalService pedalService;
  late GearboxService gearbox;

  final angles = [270.0, 360.0, 450.0, 540.0, 720.0, 900.0];
  final selectedAngle = 450.0.obs;

  final gearOptions = ["Auto", 5, 6, 7, 8];
  final selectedGearCount = 5.obs;

  // -------------------------
  // NEW AUTO GEAR SUPPORT
  // -------------------------
  final autoGear = "P".obs;

  int _gearToCode(String g) {
    switch (g) {
      case "P":
        return 1;
      case "D":
        return 2;
      case "S":
        return 3;
      case "R":
        return 9;
      case "N":
        return 10;
    }
    return 10;
  }

  void setAutoGear(String g) {
    autoGear.value = g;
    sendGear(_gearToCode(g));
  }

  // -------------------------

  @override
  void onInit() {
    super.onInit();

    udp = UdpService(onData: _processServerLine);

    ever(udp.connected, (connected) {
      if (connected == true) {
        // ToastUtils.successToast("UDP Socket Ready");
      } else {
        ToastUtils.failureToast("UDP Socket Closed");
      }
    });

    ever(udp.serverAlive, (alive) {
      if (alive == true) {
        ToastUtils.successToast("Connected to vJoy Server");
      } else {
        ToastUtils.failureToast("Lost Connection to Server");
      }
    });

    steering = SteeringService(sendSteer, () {})
      ..maxAngle.value = selectedAngle.value;

    pedalService = PedalService(pedal, sendPedals, () {});
    gearbox = GearboxService(sendGear)
      ..setAvailableGears(selectedGearCount.value);

    udp.connect();
  }

  @override
  void onClose() {
    udp.dispose();
    super.onClose();
  }

  void _processServerLine(String line) {}

  void sendSteer(double v) => udp.send(v.toStringAsFixed(6));

  void sendPedals(double thr, double brk) {
    udp.send("THR:${thr.toStringAsFixed(3)}");
    udp.send("BRK:${brk.toStringAsFixed(3)}");
  }

  void sendGear(int g) => udp.send("GEAR:$g");

  void sendHandbrake(bool pressed) {
    handbrake.value = pressed;
    udp.send("HB:${pressed ? 1 : 0}");
  }

  void connectVJoy() => udp.connect();

  void setSteeringAngle(double a) {
    selectedAngle.value = a;
    steering.maxAngle.value = a;
  }

  void setGearCount(int g) {
    selectedGearCount.value = g;
    gearbox.setAvailableGears(g);
  }

  void toggleConnection() {
    if (udp.connected.value) {
      udp.dispose();
      udp.connected.value = false;
      ToastUtils.failureToast("Disconnected");
    } else {
      udp.connect();
      ToastUtils.infoToast("Connecting…");
    }
  }

  void sendAction(String action, {bool holdStart = false, bool holdEnd = false}) {
    final normalized = action.toUpperCase().trim();

    // allowed actions
    const valid = {
      "FIX",
      "FLIP",
      "MODE",
      "IGN",
      "FOG",
      "HEAD",
      "HORN",
      "LEFT",
      "HAZ",
      "RIGHT",
      "DIFF",
      "ESC",
      "4WD",
    };

    if (!valid.contains(normalized)) {
      print("Unknown action: $action");
      return;
    }

    // ----- HOLD START -----
    if (holdStart) {
      udp.send("ACT_HOLD_START:$normalized");
      return;
    }

    // ----- HOLD END -----
    if (holdEnd) {
      udp.send("ACT_HOLD_END:$normalized");
      return;
    }

    // ----- NORMAL TAP -----
    udp.send("ACT:$normalized");
  }


}
