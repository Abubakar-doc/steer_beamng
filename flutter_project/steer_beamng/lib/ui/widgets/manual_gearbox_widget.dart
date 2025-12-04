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
          controller.gearbox.onDrag(d.localPosition, Size(size, size)),
      onPanUpdate: (d) =>
          controller.gearbox.onDrag(d.localPosition, Size(size, size)),
      onPanEnd: (_) => controller.gearbox.onDragEnd(Size(size, size)),
      child: Obx(() {
        final gear = controller.gearbox.currentGear.value;
        final knobSize = size * 0.18;
        final gearCount = controller.selectedGearCount.value;

        final knobPos = _gearPosition(gear, size, gearCount);
        final colCount = _getColumnCount(gearCount);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Stack(
            alignment: Alignment.center,
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
                  duration: const Duration(milliseconds: 80),
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
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

  // -----------------------------
  // COLUMN COUNT LOGIC YOU WANTED
  // -----------------------------
  int _getColumnCount(int gearCount) {
    int col = (gearCount / 2).ceil();
    bool lastOdd = gearCount % 2 == 1;

    if (!lastOdd) return col + 1; // Even number → add R column
    return col; // Odd number → R stays under last column
  }

  List<double> _getCols(int colCount, double w) {
    List<double> cols = [];
    double step = 1 / (colCount + 1);

    for (int i = 1; i <= colCount; i++) {
      cols.add(w * (step * i));
    }

    return cols;
  }

  // -----------------------------
  // KNOB POSITION LOGIC
  // -----------------------------
  Offset _gearPosition(int gear, double size, int gearCount) {
    final top = size * 0.22;
    final mid = size * 0.50;
    final bottom = size * 0.78;

    int colCount = _getColumnCount(gearCount);
    List<double> cols = _getCols(colCount, size);

    if (gear == 0) return Offset(cols[colCount ~/ 2], mid);

    if (gear == -1) return Offset(cols.last, bottom);

    int index = ((gear - 1) ~/ 2);
    if (index >= cols.length) index = cols.length - 1;

    double x = cols[index];
    double y = gear.isOdd ? top : bottom;

    return Offset(x, y);
  }

  // -----------------------------
  // LABELS
  // -----------------------------
  Widget _buildGearLabels(double size, int gearCount) {
    final top = size * 0.05;
    final bottom = size * 0.88;

    int colCount = _getColumnCount(gearCount);
    List<double> cols = _getCols(colCount, size);
    List<Widget> labels = [];

    for (int col = 0; col < colCount; col++) {
      int odd = col * 2 + 1;
      int even = odd + 1;

      if (odd <= gearCount) {
        labels.add(Positioned(
          left: cols[col] - 10,
          top: top,
          child: _label("$odd"),
        ));
      }

      if (even <= gearCount) {
        labels.add(Positioned(
          left: cols[col] - 10,
          top: bottom,
          child: _label("$even"),
        ));
      } else if (col == colCount - 1) {
        labels.add(Positioned(
          left: cols[col] - 10,
          top: bottom,
          child: _label("R"),
        ));
      }
    }

    return Stack(children: labels);
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HPatternPainter extends CustomPainter {
  final int gearCount;

  _HPatternPainter(this.gearCount);

  int _getColumnCount(int gearCount) {
    int cols = (gearCount / 2).ceil();
    bool lastOdd = gearCount % 2 == 1; // 5,7 → true
    return lastOdd ? cols : cols + 1;  // even → extra R column
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

      bool isPureRColumn = isLast && !hasTop && !hasBottom;          // 6,8 etc
      bool isOddPlusRColumn = isLast && hasTop && !hasBottom;        // 5/R, 7/R

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
        canvas.drawLine(
          Offset(cols[col], top),
          Offset(cols[col], mid),
          paint,
        );
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


