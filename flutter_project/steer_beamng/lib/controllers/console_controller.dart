import 'dart:io';

import 'package:get/get.dart';
import 'package:steer_beamng/services/auto_gearbox_service.dart';
import 'package:steer_beamng/services/pedal_service.dart';
import 'package:steer_beamng/services/steering_service.dart';
import 'package:steer_beamng/services/network_service.dart';
import 'package:steer_beamng/services/gearbox_service.dart';
import 'package:steer_beamng/utils/logger.dart';
import 'package:steer_beamng/utils/toast_utils.dart';

class ConsoleController extends GetxController {
  late NetworkService udp;

  final useAutoGearbox = false.obs;
  final pedal = 0.0.obs;
  final handbrake = false.obs;

  late AutoGearboxService autoService;
  late SteeringService steering;
  late PedalService pedalService;
  late GearboxService gearbox;

  final angles = [270.0, 360.0, 450.0, 540.0, 720.0, 900.0];
  final selectedAngle = 450.0.obs;

  final gearOptions = ["Auto", 5, 6, 7, 8];
  final selectedGearCount = 5.obs;

  final autoGear = "P".obs;

  @override
  void onInit() {
    super.onInit();

    udp = NetworkService(onData: _processServerLine);

    autoService = AutoGearboxService((g) {
      sendGear(_convertAuto(g));
    });

    ever(udp.connected, (v) {
      if (v == true) {
        Logger.success("UDP socket ready", tag: "CONSOLE");
      }
    });

    ever(udp.serverAlive, (alive) {
      if (alive == true) {
        final name = udp.connectedServer?.name ?? "Server";
        ToastUtils.successToast("Connected to $name");
      } else {
        ToastUtils.failureToast("Disconnected");
      }
    });

    steering = SteeringService(sendSteer, () {})
      ..maxAngle.value = selectedAngle.value;

    pedalService = PedalService(pedal, sendPedals, () {});
    gearbox = GearboxService(sendGear)
      ..setAvailableGears(selectedGearCount.value);

    // 🔹 start discovery ONLY
    udp.start();
  }

  @override
  void onClose() {
    udp.dispose();
    super.onClose();
  }

  // ---------- USER SELECTS SERVER ----------
  void connectToServer(InternetAddress ip) {
    udp.connectToServer(ip);
    ToastUtils.infoToast("Connecting to ${ip.address}");
  }

  // ---------- SENDERS ----------
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

  // ---------- AUTO GEAR ----------
  int _convertAuto(String g) {
    switch (g) {
      case "P":
        return 1;
      case "R":
        return 9;
      case "N":
        return 10;
      case "D":
        return 2;
      case "S":
        return 3;
    }
    return 10;
  }

  void setAutoGear(String g) {
    autoGear.value = g;
    sendGear(_convertAuto(g));
  }

  // ---------- UI SETTINGS ----------
  void setSteeringAngle(double a) {
    selectedAngle.value = a;
    steering.maxAngle.value = a;
  }

  void setGearCount(int g) {
    selectedGearCount.value = g;
    gearbox.setAvailableGears(g);
  }

  // ---------- ACTIONS ----------
  void sendAction(
    String action, {
    bool holdStart = false,
    bool holdEnd = false,
  }) {
    final normalized = action.toUpperCase().trim();

    if (holdStart) {
      udp.send("ACT_HOLD_START:$normalized");
      return;
    }

    if (holdEnd) {
      udp.send("ACT_HOLD_END:$normalized");
      return;
    }

    udp.send("ACT:$normalized");
  }

  void sendCamera(double x, double y) {
    udp.send("CAMX:${x.toStringAsFixed(3)}");
    udp.send("CAMY:${y.toStringAsFixed(3)}");
  }

  void sendCameraReset() => udp.send("ACT:CAMRESET");
  void sendCameraChange() => udp.send("ACT:CAMCHANGE");
  void sendCameraBehind() => udp.send("ACT:CAMBEHIND");

  void _processServerLine(String line) {}
}
