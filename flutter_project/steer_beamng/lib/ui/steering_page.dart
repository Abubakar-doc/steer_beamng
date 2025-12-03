import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import '../controllers/steering_controller.dart';

class Console extends GetView<SteeringController> {
  const Console({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final size =
                math.min(constraints.maxWidth, constraints.maxHeight) * 0.6;
            final pedalHeight = constraints.maxHeight * 0.7;

            return Stack(
              children: [
                // vJoy reconnect icon (top-right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Obx(
                        () => IconButton(
                      icon: controller.vjoyConnected.value
                          ? const Icon(Icons.wifi, color: Colors.green)
                          : const Icon(Icons.wifi_off_outlined, color: Colors.red),
                      iconSize: 34,
                      onPressed: controller.connectVJoyServer,
                      tooltip: "Reconnect vJoy",
                    ),
                  ),
                ),

                // steering wheel (bottom-left)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => controller.onPanStart(d, size),
                    onPanUpdate: (d) => controller.onPanUpdate(d, size),
                    onPanEnd: (_) => controller.onPanEnd(),
                    child: Obx(
                          () => SizedBox(
                        width: size,
                        height: size,
                        child: Transform.rotate(
                          angle: controller.wheelDeg.value * math.pi / 180,
                          child: Image.asset(
                            AssetsHelper.steering,
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // accel / brake pedal PNG (right-center, springs back)
                Positioned(
                  right: 24,
                  bottom: 16,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) => controller.onPedalPanStart(),
                    onPanUpdate: (d) =>
                        controller.onPedalPanUpdate(d, pedalHeight),
                    onPanEnd: (_) => controller.onPedalPanEnd(),
                    child: SizedBox(
                      width: 80,
                      height: pedalHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // track / background
                          Container(
                            width: 10,
                            height: pedalHeight,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                          ),
                          // pedal image moving up/down
                          Obx(
                                () => Align(
                              // pedal.value: -1 (brake, bottom) .. 0 .. 1 (accel, top)
                              alignment:
                              Alignment(0, -controller.pedal.value),
                              child: Image.asset(
                                AssetsHelper.pedal,
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
