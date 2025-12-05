import 'package:get/get.dart';
import 'package:flutter/material.dart';

class GearboxService {
  final currentGear = 0.obs;       // -1 = R, 0 = N, 1–8 forward gears
  final availableGears = 5.obs;    // forward gears only
  final Function(int) sendGear;    // sends vJoy-compatible gear value

  Offset lastDrag = Offset.zero;

  GearboxService(this.sendGear);

  // Track drag movement
  void onDrag(Offset pos, Size size) {
    lastDrag = pos;

    int snap = _detectGear(pos, size);

    // Update UI immediately
    currentGear.value = snap;

    // Send gear instantly
    sendGear(_convertGearToVJoy(snap));
  }


  // Commit gear selection at end of drag
  void onDragEnd(Size size) {
    int snap = _detectGear(lastDrag, size);
    currentGear.value = snap;

    // ⭐ SEND VJOY VALUE
    sendGear(_convertGearToVJoy(snap));
  }

  // ----------------------------------------------------------
  // vJOY MAPPING
  // ----------------------------------------------------------
  // R = 9
  // N = 10
  // 1–8 = 1–8
  int _convertGearToVJoy(int gear) {
    if (gear == 0) return 10;  // Neutral → 10
    if (gear == -1) return 9;  // Reverse → 9
    return gear;               // Forward gears stay the same
  }

  // ----------------------------------------------------------
  // GRID COLUMN LOGIC (matches UI 100%)
  // ----------------------------------------------------------
  int _getColumnCount(int gearCount) {
    int base = (gearCount / 2).ceil();  // pairs → columns
    bool lastOdd = gearCount % 2 == 1;  // 5,7 → odd → R shares last col
    return lastOdd ? base : base + 1;   // even count → add R column
  }

  List<double> _getCols(int colCount, Size s) {
    List<double> cols = [];
    double step = 1 / (colCount + 1);
    for (int i = 1; i <= colCount; i++) {
      cols.add(s.width * (step * i));
    }
    return cols;
  }

  // ----------------------------------------------------------
  // SLOT MAP (top/bottom positions for each gear + R)
  // ----------------------------------------------------------
  Map<int, Offset> _slotMap(Size s) {
    int gearCount = availableGears.value;
    int colCount = _getColumnCount(gearCount);
    List<double> cols = _getCols(colCount, s);

    final top = s.height * 0.22;
    final bottom = s.height * 0.78;

    Map<int, Offset> slots = {};

    for (int col = 0; col < colCount; col++) {
      int odd = col * 2 + 1;   // 1,3,5,7
      int even = odd + 1;      // 2,4,6,8

      // TOP ROW (odd gears)
      if (odd <= gearCount) {
        slots[odd] = Offset(cols[col], top);
      }

      // BOTTOM ROW (even gears)
      if (even <= gearCount) {
        slots[even] = Offset(cols[col], bottom);
      }

      // R logic: only when last column & no even gear exists
      bool isLast = col == colCount - 1;

      if (isLast && even > gearCount) {
        slots[-1] = Offset(cols[col], bottom);
      }
    }

    return slots;
  }

  // ----------------------------------------------------------
  // DETECT NEAREST GEAR SLOT
  // ----------------------------------------------------------
  int _detectGear(Offset p, Size s) {
    final mid = s.height * 0.50;
    final neutralZone = s.height * 0.18;

    // Neutral detection
    if ((p.dy - mid).abs() < neutralZone) {
      return 0;
    }

    final slots = _slotMap(s);
    const snapRadius = 95.0;

    int bestGear = 0;
    double bestDist = double.infinity;

    slots.forEach((gear, pos) {
      double dist = (p - pos).distance;

      if (dist < bestDist && dist <= snapRadius) {
        bestDist = dist;
        bestGear = gear;
      }
    });

    return bestGear;
  }

  // Set how many forward gears exist
  void setAvailableGears(int count) {
    availableGears.value = count.clamp(1, 8);
  }
}
