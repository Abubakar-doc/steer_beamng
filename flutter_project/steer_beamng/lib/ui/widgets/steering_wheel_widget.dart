import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class SteeringWheelWidget extends StatelessWidget {
  final ConsoleController controller;
  final double size;

  const SteeringWheelWidget(this.controller, this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => controller.steering.onStart(d, size),
      onPanUpdate: (d) => controller.steering.onMove(d, size),
      onPanEnd: (_) => controller.steering.onEnd(),
      child: Obx(
            () => SizedBox(
          width: size,
          height: size,
          child: Transform.rotate(
            angle:
            controller.steering.wheelDeg.value * math.pi / 180,
            child: Image.asset(
              AssetsHelper.steering,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
