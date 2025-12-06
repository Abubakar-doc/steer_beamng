import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class GearboxService {
  final currentGear = 0.obs;     // -1 = R, 0 = N, 1–8 = forward
  final availableGears = 5.obs;
  final Function(int) sendGear;

  Offset lastFingerPos = Offset.zero;
  Offset fingerStart = Offset.zero;
  Offset knobStart = Offset.zero;
  Offset dragOffset = Offset.zero;

  final visualOffset = Offset.zero.obs;

  GearboxService(this.sendGear);

  // -------------------------
  // USER TOUCHES SCREEN
  // -------------------------
  void startDrag(Offset finger, Size s) {
    fingerStart = finger;

    // knob's true world-position
    knobStart = getKnobPos(s);

    // compute offset so knob syncs to finger
    dragOffset = fingerStart - knobStart;
  }

  // -------------------------
  // USER DRAGS
  // -------------------------
  void updateDrag(Offset finger, Size s) {
    lastFingerPos = finger;

    // move gearbox UI visually
    visualOffset.value = finger - dragOffset;

    // simulated knob coordinates
    Offset simulated = finger - dragOffset;

    // detect nearest gear or neutral
    int snap = _detectGear(simulated, s);

    // only update when actual change
    if (snap != currentGear.value) {
      currentGear.value = snap;
      sendGear(_convertGearToVJoy(snap));
    }
  }

  // -------------------------
  // USER RELEASES
  // -------------------------
  void endDrag(Size s) {
    visualOffset.value = Offset.zero;
  }

  // ----------------------------------------------------------
  // Knob position based on current gear slot
  // ----------------------------------------------------------
  Offset getKnobPos(Size s) {
    final slots = _slotMap(s);
    return slots[currentGear.value] ?? Offset(s.width / 2, s.height / 2);
  }

  // ----------------------------------------------------------
  // vJoy gear mapping
  // ----------------------------------------------------------
  int _convertGearToVJoy(int gear) {
    if (gear == 0) return 10;  // Neutral
    if (gear == -1) return 9;  // Reverse
    return gear;
  }

  // ----------------------------------------------------------
  // Slot positions (H-pattern)
  // ----------------------------------------------------------
  Map<int, Offset> _slotMap(Size s) {
    int gearCount = availableGears.value;
    int colCount = (gearCount / 2).ceil();
    if (gearCount % 2 == 0) colCount++;

    double step = 1 / (colCount + 1);
    List<double> cols =
    List.generate(colCount, (i) => s.width * (step * (i + 1)));

    final top = s.height * 0.22;
    final bottom = s.height * 0.78;

    Map<int, Offset> slots = {};

    for (int col = 0; col < colCount; col++) {
      int odd = col * 2 + 1;
      int even = odd + 1;

      if (odd <= gearCount) slots[odd] = Offset(cols[col], top);
      if (even <= gearCount) slots[even] = Offset(cols[col], bottom);

      if (col == colCount - 1 && even > gearCount) {
        slots[-1] = Offset(cols[col], bottom);
      }
    }

    return slots;
  }

  // ----------------------------------------------------------
  // NEUTRAL + GEAR DETECTION (FINAL FIXED VERSION)
  // ----------------------------------------------------------
  int _detectGear(Offset p, Size s) {
    final top = s.height * 0.22;
    final bottom = s.height * 0.78;

    // Strong neutral zone
    final neutralTop = top + 40;
    final neutralBottom = bottom - 40;

    final slots = _slotMap(s);
    const snapRadius = 75.0;

    // 1) Look for closest gear
    int bestGear = 999;
    double bestDist = double.infinity;

    slots.forEach((gear, pos) {
      double dist = (p - pos).distance;
      if (dist < bestDist) {
        bestDist = dist;
        bestGear = gear;
      }
    });

    // 2) Neutral is allowed ONLY inside central Y band
    bool inNeutralY = p.dy > neutralTop && p.dy < neutralBottom;

    // 3) If in neutral zone and NOT very close → NEUTRAL
    if (inNeutralY && bestDist > snapRadius * 0.6) {
      return 0;
    }

    // 4) Else if close to a gear → snap
    if (bestDist <= snapRadius) {
      return bestGear;
    }

    // 5) fallback
    return 0;
  }


  void setAvailableGears(int count) {
    availableGears.value = count.clamp(1, 8);
  }

}
