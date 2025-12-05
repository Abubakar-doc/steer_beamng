import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class AutoGearboxWidget extends StatelessWidget {
  final ConsoleController controller;
  final double height;

   AutoGearboxWidget(this.controller, {this.height = 180, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => _onDrag(d.localPosition),
      onPanUpdate: (d) => _onDrag(d.localPosition),
      onPanEnd: (_) => _onDragEnd(),
      child: Obx(() {
        final gear = controller.autoGear.value;
        final knobSize = 32.0;

        final knobPos = _gearPos(gear);

        return Container(
          width: 70,
          height: height,
          color: Colors.black,
          child: Stack(
            children: [
              // RAIL
              Positioned.fill(
                child: CustomPaint(
                  painter: _AutoRailPainter(),
                ),
              ),

              // GEAR LABELS
              ..._buildLabels(),

              // KNOB
              Positioned(
                left: 35 - knobSize / 2,
                top: knobPos - knobSize / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  //   POSITIONS FOR GEARS
  // ---------------------------------------------------------------
  final _gears = ["S", "D", "N", "R", "P"];

  double _gearPos(String g) {
    final index = _gears.indexOf(g);
    final step = height / (_gears.length);
    return step * index + step * 0.5;
  }

  String _nearestGear(double y) {
    final step = height / (_gears.length);
    final index = (y / step).round().clamp(0, _gears.length - 1);
    return _gears[index];
  }

  // ---------------------------------------------------------------
  //   DRAG LOGIC
  // ---------------------------------------------------------------
  void _onDrag(Offset pos) {
    final g = _nearestGear(pos.dy);

    // Update UI immediately
    controller.autoGear.value = g;

    // Also send gear live instead of waiting
    controller.setAutoGear(g);
  }


  void _onDragEnd() {
    // Send gear after snapping
    controller.setAutoGear(controller.autoGear.value);
  }

  // ---------------------------------------------------------------
  //   LABELS
  // ---------------------------------------------------------------
  List<Widget> _buildLabels() {
    final step = height / _gears.length;

    return List.generate(_gears.length, (i) {
      return Positioned(
        left: 8,
        top: step * i + step / 2 - 12,
        child: Text(
          _gears[i],
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

// ---------------------------------------------------------------
//   PAINT: SINGLE VERTICAL RAIL
// ---------------------------------------------------------------
class _AutoRailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // rail from top to bottom
    canvas.drawLine(
      Offset(s.width * 0.55, 10),
      Offset(s.width * 0.55, s.height - 10),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
