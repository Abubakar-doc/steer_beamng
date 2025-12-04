import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class WifiStatusWidget extends StatelessWidget {
  final ConsoleController controller;
  const WifiStatusWidget(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double ms = controller.tcp.pingMs.value;
      Color pingColor;

      if (!controller.tcp.connected.value) {
        pingColor = Colors.red;
      } else if (ms < 40) {
        pingColor = Colors.green;
      } else if (ms < 100) {
        pingColor = Colors.yellow;
      } else {
        pingColor = Colors.red;
      }

      return Row(
        children: [
          IconButton(
            icon: Icon(
              controller.tcp.connected.value ? Icons.wifi : Icons.wifi_off,
              color: pingColor,
            ),
            iconSize: 30,
            onPressed: controller.connectVJoy,
          ),
          if (controller.tcp.connected.value)
            Text(
              "${ms.toStringAsFixed(0)} ms",
              style: TextStyle(
                fontSize: 14,
                color: pingColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      );
    });
  }
}
