import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'package:steer_beamng/ui/widgets/gear_count_dropdown.dart';
import 'package:steer_beamng/ui/widgets/manual_gearbox_widget.dart';
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

            return Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: WifiStatusWidget(controller),
                ),

                Positioned(
                  top: 10,
                  left: 120,
                  child: SteeringAngleDropdown(controller),
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

                Positioned(
                  top: 10,
                  left: 200,
                  child: GearCountDropdown(controller),
                ),

                Positioned(
                  right: 100,
                  bottom: 100,
                  child: ManualGearboxWidget(controller, 180),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
