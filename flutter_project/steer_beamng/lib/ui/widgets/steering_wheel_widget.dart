import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class SteeringWheelWidget extends StatefulWidget {
  final ConsoleController controller;
  final double size;

  const SteeringWheelWidget(this.controller, this.size, {super.key});

  @override
  State<SteeringWheelWidget> createState() => _SteeringWheelWidgetState();
}

class _SteeringWheelWidgetState extends State<SteeringWheelWidget> {
  bool _flashing = false;

  void _startFlashing() async {
    _flashing = true;
    while (_flashing) {
      widget.controller.sendAction("FLASH");
      await Future.delayed(const Duration(milliseconds: 140));
    }
  }

  void _stopFlashing() {
    _flashing = false;
  }

  bool _tapInsideCenter(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (position - center).distance;
    return distance < widget.size * 0.22; // center "touch zone"
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onPanStart: (d) {
        widget.controller.steering.onStart(d, widget.size);
      },
      onPanUpdate: (d) {
        widget.controller.steering.onMove(d, widget.size);
      },
      onPanEnd: (_) {
        widget.controller.steering.onEnd();
      },

      // T A P   C E N T E R   → HORN
      onTapDown: (d) {
        if (_tapInsideCenter(d.localPosition)) {
          widget.controller.sendAction("Horn");
        }
      },

      // H O L D   C E N T E R  → FLASH SPAM
      onLongPressStart: (d) {
        if (_tapInsideCenter(d.localPosition)) {
          _startFlashing();
        }
      },
      onLongPressEnd: (_) => _stopFlashing(),
      onLongPressCancel: () => _stopFlashing(),

      child: Obx(
        () => SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.rotate(
            angle: widget.controller.steering.wheelDeg.value * math.pi / 180,
            child: Image.asset(
              AssetsHelper.steering,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
