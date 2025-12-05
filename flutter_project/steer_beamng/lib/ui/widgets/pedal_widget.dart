import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class PedalWidget extends StatelessWidget {
  final ConsoleController controller;
  final double pedalHeight;

  const PedalWidget(this.controller, this.pedalHeight, {super.key});

  static const double hbZoneWidth = 40;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: pedalHeight,
      child: Stack(
        children: [
          // ============================================================
          // LEFT SIDE — HANDBRAKE ZONE (tap + hold → ON, release → OFF)
          // ============================================================
          Positioned(
            left: 0,
            width: hbZoneWidth,
            height: pedalHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,

              // TAP should ONLY turn ON
              onTap: () => controller.sendHandbrake(true),

              // HOLD turns on, release turns off
              onPanStart: (_) => controller.sendHandbrake(true),
              onPanEnd: (_) => controller.sendHandbrake(false),
              onPanCancel: () => controller.sendHandbrake(false),

              child: Obx(() {
                return Align(
                  alignment: Alignment(0, -controller.pedal.value),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.handbrake.value
                            ? Colors.redAccent
                            : Colors.white38,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "P",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: controller.handbrake.value
                            ? Colors.redAccent
                            : Colors.white38,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ============================================================
          // RIGHT SIDE — PEDAL CONTROL
          // ============================================================
          Positioned(
            left: hbZoneWidth,
            width: 130 - hbZoneWidth,
            height: pedalHeight,
            child: Obx(() {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,

                onPanStart: (_) => controller.pedalService.onStart(),

                onPanUpdate: (d) {
                  controller.pedalService.onMove(d, pedalHeight);

                  // ENTER HB ZONE → ON
                  if (d.globalPosition.dx < _hbGlobalRightEdge(context)) {
                    controller.sendHandbrake(true);
                  } else {
                    controller.sendHandbrake(false);
                  }
                },

                onPanEnd: (_) {
                  controller.pedalService.onEnd();
                  controller.sendHandbrake(false);
                },

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

                    Align(
                      alignment: Alignment(0, -controller.pedal.value),
                      child: Image.asset(
                        AssetsHelper.pedal,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _hbGlobalRightEdge(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return 0;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    return topLeft.dx + hbZoneWidth;
  }
}
