import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/constants/routes_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'package:steer_beamng/ui/widgets/app_button.dart';
import 'package:steer_beamng/ui/widgets/camera_button.dart';
import 'package:steer_beamng/ui/widgets/camera_joystick.dart';
import 'package:steer_beamng/ui/widgets/gear_selector_widget.dart';
import 'package:steer_beamng/ui/widgets/manual_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/auto_gearbox_widget.dart';
import 'package:steer_beamng/ui/widgets/pedal_widget.dart';
import 'package:steer_beamng/ui/widgets/steering_angle_dropdown.dart';
import 'package:steer_beamng/ui/widgets/steering_wheel_widget.dart';
import 'package:steer_beamng/ui/widgets/vehicle_dashboard.dart';
import 'package:steer_beamng/ui/widgets/wifi_status_widget.dart';

class ConsoleView extends GetView<ConsoleController> {
  const ConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (ctx, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          // LANDSCAPE SCALING (height is the boss)
          final s = h * 0.25;

          // Sizes
          final topRowWidth = w * 0.42;

          final wheelSize = math.min(h * 0.62, w * 0.45); // bigger now
          final pedalH = h * 0.90;

          final dashBottomOffset = h * 0.07;

          final gearRightOffset = w * 0.20;
          final gearBottomOffset = h * 0.08;
          final gearSize = h * 0.55;

          final topBtnIcon = h * 0.050;
          final topBtnFont = h * 0.030;
          final topBtnSpacing = h * 0.02;
          final joyTop = h * 0.07;
          final joyRight = h * 0.50;

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // ---------------- CAMERA CONTROLS ----------------
                    Positioned(
                      right: joyRight,
                      top: joyTop,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT BUTTONS
                          Column(
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: appBtn(
                                  label: "",
                                  asset: AssetsHelper.zoomIn,
                                  iconSize: 28,
                                  fontSize: 0,

                                  onPressed: () {
                                    controller.sendAction("CAMZOOMIN");
                                  },

                                  onHoldStart: () {
                                    controller.sendAction("CAMZOOMIN", holdStart: true);
                                  },

                                  onHoldEnd: () {
                                    controller.sendAction("CAMZOOMIN", holdEnd: true);
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                height: 40,
                                width: 40,
                                child: appBtn(
                                  label: "",
                                  asset: AssetsHelper.zoomOut,
                                  iconSize: 28,
                                  fontSize: 0,

                                  onPressed: () {
                                    controller.sendAction("CAMZOOMOUT");
                                  },

                                  onHoldStart: () {
                                    controller.sendAction("CAMZOOMOUT", holdStart: true);
                                  },

                                  onHoldEnd: () {
                                    controller.sendAction("CAMZOOMOUT", holdEnd: true);
                                  },
                                ),
                              ),
                            ],
                          ),


                          SizedBox(width: 20),

                          // JOYSTICK
                          CameraJoystick(
                            onChanged: (x, y) => controller.sendCamera(x, y),
                            onReset: controller.sendCameraReset,
                          ),

                          SizedBox(width: 20),

                          Column(
                            children: [
                              CamBtn(
                                asset: AssetsHelper.camChange,
                                iconSize: 28,
                                onTap: controller.sendCameraChange,
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: appBtn(
                                  label: "",
                                  asset: AssetsHelper.camBehind,
                                  iconSize: 28,
                                  fontSize: 0,

                                  onPressed: () {
                                    controller.sendAction("CAMBEHIND");
                                  },

                                  onHoldStart: () {
                                    controller.sendAction(
                                      "CAMBEHIND",
                                      holdStart: true,
                                    );
                                  },

                                  onHoldEnd: () {
                                    controller.sendAction(
                                      "CAMBEHIND",
                                      holdEnd: true,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ---------------- DASHBOARD ----------------
                    Positioned(
                      bottom: dashBottomOffset,
                      left: -s,
                      right: 0,
                      child: Center(
                        child: VehicleDashboard((action) {
                          controller.sendAction(action);
                        }),
                      ),
                    ),

                    // ---------------- GEARBOX (BIGGER) ----------------
                    Obx(() {
                      return controller.useAutoGearbox.value
                          ? Positioned(
                              right: gearRightOffset,
                              bottom: gearBottomOffset,
                              child: SizedBox(
                                height: gearSize,
                                child: AutoGearboxWidget(controller, gearSize),
                              ),
                            )
                          : Positioned(
                              right: gearRightOffset,
                              bottom: gearBottomOffset,
                              child: SizedBox(
                                width: gearSize,
                                child: ManualGearboxWidget(
                                  controller,
                                  gearSize,
                                ),
                              ),
                            );
                    }),

                    // ---------------- TOP BAR ----------------
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: w * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row 1
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.settings);
                                },
                                child: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: w * 0.02),
                              WifiStatusWidget(controller),
                              SizedBox(width: w * 0.02),
                              SteeringAngleDropdown(controller),
                              SizedBox(width: w * 0.02),
                              GearSelectorWidget(controller),
                            ],
                          ),
                          SizedBox(height: h * 0.015),

                          // Top row 2 (50% width)
                          SizedBox(
                            width: topRowWidth,
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: h * 0.13,
                                    child: appBtn(
                                      label: "Fix",
                                      asset: AssetsHelper.fix,
                                      iconSize: topBtnIcon,
                                      fontSize: topBtnFont,
                                      onPressed: () {
                                        controller.sendAction("Fix");
                                      },
                                      onHoldStart: () {
                                        controller.sendAction(
                                          "Fix",
                                          holdStart: true,
                                        );
                                      },
                                      onHoldEnd: () {
                                        controller.sendAction(
                                          "Fix",
                                          holdEnd: true,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: topBtnSpacing),

                                Expanded(
                                  child: SizedBox(
                                    height: h * 0.13,
                                    child: appBtn(
                                      label: "Flip",
                                      asset: AssetsHelper.flip,
                                      iconSize: topBtnIcon,
                                      fontSize: topBtnFont,
                                      onPressed: () =>
                                          controller.sendAction("Flip"),
                                    ),
                                  ),
                                ),
                                SizedBox(width: topBtnSpacing),

                                Expanded(
                                  child: SizedBox(
                                    height: h * 0.13,
                                    child: appBtn(
                                      label: "Mode",
                                      asset: AssetsHelper.mode,
                                      iconSize: topBtnIcon,
                                      fontSize: topBtnFont,
                                      onPressed: () =>
                                          controller.sendAction("Mode"),
                                    ),
                                  ),
                                ),
                                SizedBox(width: topBtnSpacing),

                                Expanded(
                                  child: SizedBox(
                                    height: h * 0.13,
                                    child: appBtn(
                                      label: "Ign",
                                      asset: AssetsHelper.ign,
                                      iconSize: topBtnIcon,
                                      fontSize: topBtnFont,
                                      onPressed: () =>
                                          controller.sendAction("Ign"),
                                      onHoldStart: () => controller.sendAction(
                                        "Ign",
                                        holdStart: true,
                                      ),
                                      onHoldEnd: () => controller.sendAction(
                                        "Ign",
                                        holdEnd: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------------- STEERING WHEEL (BIGGER) ----------------
                    Positioned(
                      left: w * 0.04,
                      bottom: h * 0.02,
                      child: SteeringWheelWidget(controller, wheelSize),
                    ),

                    // ---------------- PEDALS ----------------
                    Positioned(
                      right: w * 0.03,
                      bottom: h * 0.02,
                      child: PedalWidget(controller, pedalH),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
