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

            return Stack(
              children: [
                // vJoy reconnect icon (top-right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Obx(
                        () => IconButton(
                      icon: controller.vjoyConnected.value
                          ? const Icon(Icons.usb, color: Colors.green)
                          : const Icon(Icons.usb_off, color: Colors.red),
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

                // accel / brake 2-in-1 vertical pedal (right side)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 80,
                    height: constraints.maxHeight * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Obx(
                            () => RotatedBox(
                          quarterTurns: 3, // horizontal slider -> vertical
                          child: Slider(
                            value: controller.pedal.value,
                            min: -1.0, // full brake
                            max: 1.0,  // full accel
                            onChanged: controller.onPedalChanged,
                            activeColor: Colors.greenAccent,
                            inactiveColor: Colors.grey.shade700,
                          ),
                        ),
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
