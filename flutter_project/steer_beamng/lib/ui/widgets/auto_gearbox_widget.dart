import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class AutoGearboxWidget extends StatelessWidget {
  final ConsoleController controller;
  final double height;

  AutoGearboxWidget(this.controller, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    final service = controller.autoService;

    return GestureDetector(
      onPanStart: (d) => service.startDrag(d.localPosition, height),
      onPanUpdate: (d) => service.updateDrag(d.localPosition, height),
      onPanEnd: (_) => service.endDrag(height),

      child: Obx(() {
        final knobPos = service.getKnobPos(height);
        final offset = service.visualOffset.value;

        return Transform.translate(
          offset: -offset,
          child: Container(
            width: Get.height * 0.5,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
                color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _AutoRailPainter()),
                ),

                ..._labels(height),

                Positioned(
                  left: Get.height * 0.5 * 0.55 - 18,
                  top: knobPos.dy - 18,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _labels(double height) {
    final gears = ["P", "R", "N", "D", "S"];
    final slot = height / gears.length;

    return List.generate(gears.length, (i) {
      return Positioned(
        left: Get.height * 0.5 * 0.30,
        top: slot * i + slot / 2 - 12,
        child: Text(
          gears[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}

// ⭐ RAIL PAINTER RE-INTRODUCED
class _AutoRailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(s.width * 0.55, 10),
      Offset(s.width * 0.55, s.height - 10),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
