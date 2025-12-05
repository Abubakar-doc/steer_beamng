import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class WifiStatusWidget extends StatelessWidget {
  final ConsoleController controller;
  const WifiStatusWidget(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double ms = controller.udp.pingMs.value;

      Color pingColor;
      if (!controller.udp.serverAlive.value) {
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
          // WiFi icon
          Icon(
            controller.udp.serverAlive.value ? Icons.wifi : Icons.wifi_off,
            color: pingColor,
            size: 30,
          ),

          if (controller.udp.serverAlive.value) ...[
            const SizedBox(width: 5),
            SizedBox(
              width: 50,
              child: Text(
                "${ms.toStringAsFixed(0)} ms",
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: TextStyle(
                  fontSize: 14,
                  color: pingColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(width: 8),

          // Toggle Switch
          Switch(
            value: controller.udp.connected.value,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.black,
            onChanged: (value) {
              controller.toggleConnection();
            },
          ),
        ],
      );
    });
  }
}
