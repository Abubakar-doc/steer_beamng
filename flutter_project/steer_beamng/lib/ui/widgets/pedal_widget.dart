import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class PedalWidget extends StatefulWidget {
  final ConsoleController controller;
  final double pedalHeight;

  const PedalWidget(this.controller, this.pedalHeight, {super.key});

  @override
  State<PedalWidget> createState() => _PedalWidgetState();
}

class _PedalWidgetState extends State<PedalWidget> {
  static const double hbZoneWidth = 30;

  bool _isHoldingHB = false;

  ConsoleController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: widget.pedalHeight,
      child: Stack(
        children: [
          // ============================================================
          // LEFT COLUMN — HANDBRAKE "P" BUTTON
          // ============================================================
          Positioned(
            left: 0,
            width: hbZoneWidth,
            height: widget.pedalHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,

              // STATIC TAP → toggle ON/OFF (NO HOLD)
              onTap: () {
                controller.sendHandbrake(!controller.handbrake.value);
              },

              // LONG PRESS → HOLD HB ON
              onLongPressStart: (_) {
                controller.sendHandbrake(true);
                _isHoldingHB = true;
              },
              onLongPressEnd: (_) {
                controller.sendHandbrake(false);
                _isHoldingHB = false;
              },

              // Slide-based HB (if finger moves in here)
              onHorizontalDragUpdate: (d) {
                controller.sendHandbrake(true);
                _isHoldingHB = true;
              },
              onHorizontalDragEnd: (_) {
                controller.sendHandbrake(false);
                _isHoldingHB = false;
              },

              child: Obx(() {
                return Align(
                  alignment: Alignment(0, -controller.pedal.value),
                  child: Container(
                    width: 32,
                    height: 32,
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
            height: widget.pedalHeight,
            child: Obx(() {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,

                onPanStart: (_) => controller.pedalService.onStart(),

                onPanUpdate: (d) {
                  controller.pedalService.onMove(d, widget.pedalHeight);

                  // SLIDE INTO P ZONE → HB ON
                  if (_inHBZone(context, d.globalPosition.dx)) {
                    controller.sendHandbrake(true);
                    _isHoldingHB = true;
                  } else {
                    if (_isHoldingHB) {
                      controller.sendHandbrake(false);
                      _isHoldingHB = false;
                    }
                  }
                },

                onPanEnd: (_) {
                  controller.pedalService.onEnd();

                  if (_isHoldingHB) {
                    controller.sendHandbrake(false);
                    _isHoldingHB = false;
                  }
                },

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: widget.pedalHeight,
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

  // Check if finger is inside HB zone in global coords
  bool _inHBZone(BuildContext context, double fingerX) {
    final box = context.findRenderObject() as RenderBox;
    final boxLeft = box.localToGlobal(Offset.zero).dx;
    return fingerX < boxLeft + hbZoneWidth;
  }
}
