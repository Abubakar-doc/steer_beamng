import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'package:steer_beamng/ui/widgets/gear_selector_widget.dart';
import 'package:steer_beamng/ui/widgets/manual_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/auto_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/pedal_widget.dart';
import 'package:steer_beamng/ui/widgets/steering_angle_dropdown.dart';
import 'package:steer_beamng/ui/widgets/steering_wheel_widget.dart';
import 'package:steer_beamng/ui/widgets/wifi_status_widget.dart';

class Console extends GetView<ConsoleController> {
  const Console({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (ctx, c) {
            final size = math.min(c.maxWidth, c.maxHeight) * 0.6;
            final pedalH = c.maxHeight * 0.8;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // ---------------- GEARBOX SWAP ----------------
                      Obx(() {
                        return controller.useAutoGearbox.value
                            ? Positioned(
                                right: 140,
                                bottom: 70,
                                child: AutoGearboxWidget(controller),
                              )
                            : Positioned(
                                right: 140,
                                bottom: 70,
                                child: ManualGearboxWidget(controller, 180),
                              );
                      }),

                      // ---------------- TOP ROW ----------------
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            WifiStatusWidget(controller),
                            const SizedBox(width: 20),
                            SteeringAngleDropdown(controller),
                            const SizedBox(width: 20),
                            GearSelectorWidget(
                              controller,
                            ), // <-- replaced dropdown
                          ],
                        ),
                      ),

                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: SteeringWheelWidget(controller, size),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 24,
                        child: PedalWidget(controller, pedalH),
                      ),
                    ],
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
