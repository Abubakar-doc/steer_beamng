import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class ManualGearboxWidget extends StatelessWidget {
  final ConsoleController controller;
  final double size;

  const ManualGearboxWidget(this.controller, this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) =>
          controller.gearbox.startDrag(d.localPosition, Size(size, size)),

      onPanUpdate: (d) =>
          controller.gearbox.updateDrag(d.localPosition, Size(size, size)),

      onPanEnd: (_) => controller.gearbox.endDrag(Size(size, size)),

      child: Obx(() {
        final gear = controller.gearbox.currentGear.value;
        final knobPos = controller.gearbox.getKnobPos(Size(size, size));
        final offset = controller.gearbox.visualOffset.value;

        final knobSize = size * 0.18;
        final gearCount = controller.selectedGearCount.value;

        return Transform.translate(
          offset: -offset, // ⭐ shifts whole gearbox
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _HPatternPainter(gearCount),
                ),

                _buildGearLabels(size, gearCount),

                Positioned(
                  left: knobPos.dx - knobSize / 2,
                  top: knobPos.dy - knobSize / 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
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

  Widget _buildGearLabels(double size, int gearCount) {
    final top = size * 0.05;
    final bottom = size * 0.88;

    int colCount = (gearCount / 2).ceil();
    if (gearCount % 2 == 0) colCount++;

    double step = 1 / (colCount + 1);
    List<double> cols = List.generate(colCount, (i) => size * (step * (i + 1)));

    List<Widget> labels = [];

    for (int col = 0; col < colCount; col++) {
      int odd = col * 2 + 1;
      int even = odd + 1;

      if (odd <= gearCount) {
        labels.add(
          Positioned(
            left: cols[col] - 10,
            top: top,
            child: Text(
              "$odd",
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        );
      }

      if (even <= gearCount) {
        labels.add(
          Positioned(
            left: cols[col] - 10,
            top: bottom,
            child: Text(
              "$even",
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        );
      } else if (col == colCount - 1) {
        labels.add(
          Positioned(
            left: cols[col] - 10,
            top: bottom,
            child: const Text(
              "R",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        );
      }
    }

    return Stack(children: labels);
  }
}

class _HPatternPainter extends CustomPainter {
  final int gearCount;

  _HPatternPainter(this.gearCount);

  int _getColumnCount(int gearCount) {
    int cols = (gearCount / 2).ceil();
    bool lastOdd = gearCount % 2 == 1; // 5,7 → true
    return lastOdd ? cols : cols + 1; // even → extra R column
  }

  List<double> _getCols(int colCount, Size s) {
    List<double> cols = [];
    double step = 1 / (colCount + 1);
    for (int i = 1; i <= colCount; i++) {
      cols.add(s.width * (step * i));
    }
    return cols;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final top = s.height * 0.22;
    final mid = s.height * 0.50;
    final bottom = s.height * 0.78;

    int colCount = _getColumnCount(gearCount);
    List<double> cols = _getCols(colCount, s);

    for (int col = 0; col < colCount; col++) {
      int odd = col * 2 + 1;
      int even = odd + 1;

      bool hasTop = odd <= gearCount;
      bool hasBottom = even <= gearCount;
      bool isLast = col == colCount - 1;

      bool isPureRColumn = isLast && !hasTop && !hasBottom; // 6,8 etc
      bool isOddPlusRColumn = isLast && hasTop && !hasBottom; // 5/R, 7/R

      if (isPureRColumn) {
        // Only R at bottom → half rail (mid → bottom)
        canvas.drawLine(
          Offset(cols[col], mid),
          Offset(cols[col], bottom),
          paint,
        );
      } else if (isOddPlusRColumn || (hasTop && hasBottom)) {
        // 5/R, 7/R OR full pair → full rail
        canvas.drawLine(
          Offset(cols[col], top),
          Offset(cols[col], bottom),
          paint,
        );
      } else if (hasTop) {
        // only top gear (rare)
        canvas.drawLine(Offset(cols[col], top), Offset(cols[col], mid), paint);
      } else if (hasBottom) {
        // only bottom gear
        canvas.drawLine(
          Offset(cols[col], mid),
          Offset(cols[col], bottom),
          paint,
        );
      }
    }

    // Neutral bar between first and last real column
    canvas.drawLine(
      Offset(cols.first, mid),
      Offset(cols[colCount - 1], mid),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HPatternPainter oldDelegate) =>
      oldDelegate.gearCount != gearCount;
}
