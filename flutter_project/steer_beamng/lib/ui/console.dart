import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'package:steer_beamng/ui/widgets/app_button.dart';
import 'package:steer_beamng/ui/widgets/gear_selector_widget.dart';
import 'package:steer_beamng/ui/widgets/manual_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/auto_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/pedal_widget.dart';
import 'package:steer_beamng/ui/widgets/steering_angle_dropdown.dart';
import 'package:steer_beamng/ui/widgets/steering_wheel_widget.dart';
import 'package:steer_beamng/ui/widgets/vehicle_dashboard.dart';
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
                      // ---------------- DASHBOARD (NEW) ----------------
                      Positioned(
                        bottom: 50,
                        left: -40,
                        right: 0,
                        child: Center(
                          child: VehicleDashboard((action) {
                            controller.sendAction(action);
                          }),
                        ),
                      ),
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
                            GearSelectorWidget(controller),
                            SizedBox(width: 20),
                            appBtn(
                              label: "",
                              asset: AssetsHelper.fix,
                              iconSize: 20,
                              fontSize: 0,
                              compact: true,
                              onPressed: () => controller.sendAction("Fix"), // normal tap
                              onHoldStart: () => controller.sendAction("Fix", holdStart: true),
                              onHoldEnd: () => controller.sendAction("Fix", holdEnd: true),
                            ),
                            SizedBox(width: 10),
                            appBtn(label: "", asset: AssetsHelper.flip, iconSize: 20, fontSize: 0, compact: true, onPressed: () => controller.sendAction("Flip")),
                            SizedBox(width: 10),
                            appBtn(label: "", asset: AssetsHelper.mode, iconSize: 20, fontSize: 0, compact: true, onPressed: () => controller.sendAction("Mode")),
                            SizedBox(width: 10),
                            appBtn(
                              label: "",
                              asset: AssetsHelper.ign,
                              iconSize: 20,
                              fontSize: 0,
                              compact: true,
                              onPressed: () => controller.sendAction("Ign"),
                              onHoldStart: () => controller.sendAction("Ign", holdStart: true),
                              onHoldEnd: () => controller.sendAction("Ign", holdEnd: true),
                            )


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

Widget topBtn(String label, String assetPath, ConsoleController c) {
  return InkWell(
    onTap: () => c.sendAction(label),
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(6),
      ),
      child: assetPath.endsWith(".svg")
          ? SvgPicture.asset(
        assetPath,
        width: 22,
        height: 22,
        colorFilter:
        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      )
          : Image.asset(
        assetPath,
        width: 22,
        height: 22,
        color: Colors.white,
      ),
    ),
  );
}
