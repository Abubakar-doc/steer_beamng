import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'app_button.dart';

class CameraJoystick extends StatefulWidget {
  final void Function(double x, double y) onChanged;
  final VoidCallback? onReset;

  const CameraJoystick({required this.onChanged, this.onReset, super.key});

  @override
  State<CameraJoystick> createState() => _CameraJoystickState();
}

class _CameraJoystickState extends State<CameraJoystick> {
  final ConsoleController controller = Get.find<ConsoleController>();

  double dx = 0;
  double dy = 0;

  final double radius = 50;
  final double knobRadius = 25;

  void _update(Offset o) {
    double x = o.dx - radius;
    double y = o.dy - radius;

    final dist = sqrt(x * x + y * y);
    if (dist > radius) {
      x = x / dist * radius;
      y = y / dist * radius;
    }

    setState(() {
      dx = x;
      dy = y;
    });

    widget.onChanged(x / radius, -(y / radius));
  }

  void _resetToCenter() {
    setState(() {
      dx = 0;
      dy = 0;
    });
    widget.onChanged(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => _update(d.localPosition),
      onPanUpdate: (d) => _update(d.localPosition),
      onPanEnd: (_) => _resetToCenter(),
      onDoubleTap: () {
        _resetToCenter();
        widget.onReset?.call();
      },

      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: radius * 2, height: radius * 2),

          // Outer circle
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900],
              border: Border.all(color: Colors.white30, width: 2),
            ),
          ),

          // Knob
          Positioned(
            left: dx + radius - knobRadius,
            top: dy + radius - knobRadius,
            child: Container(
              width: knobRadius * 2,
              height: knobRadius * 2,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


