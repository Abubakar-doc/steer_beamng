import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class AutoGearboxWidget extends StatelessWidget {
  final ConsoleController controller;
  final double height;

  AutoGearboxWidget(this.controller, {this.height = 180, super.key});

  // Vertical spacing from top and bottom
  final double gearPadding = 15;

  // Gear order (top to bottom visually)
  final _gears = ["S", "D", "N", "R", "P"];

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

        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Container(
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
                  left: 38 - knobSize / 2,
                  top: knobPos - knobSize / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: Colors.orange,
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
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------
  //   POSITION CALCULATIONS (with spacing)
  // ---------------------------------------------------------------

  double get _usableHeight => height - (gearPadding * 2);

  double get _step => _usableHeight / (_gears.length - 1);

  double _gearPos(String g) {
    final index = _gears.indexOf(g);
    return gearPadding + index * _step;
  }

  String _nearestGear(double y) {
    final index = ((y - gearPadding) / _step)
        .round()
        .clamp(0, _gears.length - 1);

    return _gears[index];
  }

  // ---------------------------------------------------------------
  //   DRAG LOGIC
  // ---------------------------------------------------------------
  void _onDrag(Offset pos) {
    final g = _nearestGear(pos.dy);

    controller.autoGear.value = g;
    controller.setAutoGear(g); // send live
  }

  void _onDragEnd() {
    controller.setAutoGear(controller.autoGear.value);
  }

  // ---------------------------------------------------------------
  //   LABELS WITH SPACING
  // ---------------------------------------------------------------
  List<Widget> _buildLabels() {
    return List.generate(_gears.length, (i) {
      return Positioned(
        left: 8,
        top: gearPadding + (i * _step) - 12,
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
//   PAINT: VERTICAL RAIL
// ---------------------------------------------------------------
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
