import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class PedalWidget extends StatelessWidget {
  final ConsoleController controller;
  final double pedalHeight;

  const PedalWidget(this.controller, this.pedalHeight, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: pedalHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 10,
            height: pedalHeight,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
            ),
          ),
          Obx(() {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => controller.pedalService.onStart(),
              onPanUpdate: (d) =>
                  controller.pedalService.onMove(d, pedalHeight),
              onPanEnd: (_) => controller.pedalService.onEnd(),
              child: Align(
                alignment: Alignment(0, -controller.pedal.value),
                child: Image.asset(
                  AssetsHelper.pedal,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
