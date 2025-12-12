import 'dart:io';

import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import '../services/network_service.dart';

class SettingsController extends GetxController {
  final ConsoleController console = Get.find();

  List<DiscoveredServer> get servers =>
      console.udp.discoveredServers;

  String? get favourite => console.udp.favouriteIp.value;

  InternetAddress? get connected =>
      console.udp.currentServerIp.value;

  void connect(DiscoveredServer s) {
    console.udp.connectToServer(s.ip);
  }

  void disconnect() {
    console.udp.disconnect();
  }

  void toggleFavourite(DiscoveredServer s) {
    console.udp.toggleFavourite(s.ip.address);
  }
}
