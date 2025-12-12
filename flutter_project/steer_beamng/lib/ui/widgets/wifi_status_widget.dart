import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class WifiStatusWidget extends StatelessWidget {
  final ConsoleController controller;
  const WifiStatusWidget(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alive = controller.udp.serverAlive.value;
      final ms = controller.udp.pingMs.value;

      Color color;
      if (!alive) {
        color = Colors.red;
      } else if (ms < 40) {
        color = Colors.green;
      } else if (ms < 100) {
        color = Colors.yellow;
      } else {
        color = Colors.red;
      }

      return Row(
        children: [
          Icon(
            alive ? Icons.wifi : Icons.wifi_off,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 6),
          if (alive)
            Text(
              "${ms.toStringAsFixed(0)} ms",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            )
        ],
      );
    });
  }
}
