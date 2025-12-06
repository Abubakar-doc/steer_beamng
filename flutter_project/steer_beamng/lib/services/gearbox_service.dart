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

  int lastVibratedGear = 999;

  // Debounce vibration for stability
  DateTime lastVibrationTime = DateTime.now();
  static const vibrationCooldown = Duration(milliseconds: 120);

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

    // reset vibration state
    lastVibratedGear = currentGear.value;
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

      // Debounced vibration
      final now = DateTime.now();
      if (now.difference(lastVibrationTime) > vibrationCooldown &&
          snap != lastVibratedGear) {
        vibrateForGear(snap);
        lastVibratedGear = snap;
        lastVibrationTime = now;
      }
    }
  }

  // -------------------------
  // USER RELEASES
  // -------------------------
  void endDrag(Size s) {
    visualOffset.value = Offset.zero;

    // reset vibration system next drag
    lastVibratedGear = 999;
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

    final slots = _slotMap(s);
    const snapRadius = 75.0;

    // closest gear
    int bestGear = 999;
    double bestDist = double.infinity;

    slots.forEach((gear, pos) {
      double dist = (p - pos).distance;
      if (dist < bestDist) {
        bestDist = dist;
        bestGear = gear;
      }
    });

    // movement direction
    bool movingDown = p.dy > lastFingerPos.dy;
    bool movingUp = p.dy < lastFingerPos.dy;

    // ⭐ EXPANDED SNAP for gears in direction of travel
    if (movingDown && bestDist <= snapRadius * 1.8) return bestGear;
    if (movingUp && bestDist <= snapRadius * 1.8) return bestGear;

    // ⭐ normal snap
    if (bestDist <= snapRadius) return bestGear;

    // neutral zone (weakened)
    final neutralTop = top + 70;
    final neutralBottom = bottom - 70;
    bool inNeutralY = p.dy > neutralTop && p.dy < neutralBottom;

    if (inNeutralY) return 0;

    return 0;
  }


  // ----------------------------------------------------------
  // VIBRATION MAP (Optimized)
  // ----------------------------------------------------------
  Future<void> vibrateForGear(int gear) async {
    if (!(await Vibration.hasVibrator() ?? false)) return;

    const S = 80;   // short
    const L = 220;  // long
    const gap = 70;

    List<int> p = [0];

    void pulse(int d) {
      p.add(d);
      p.add(gap);
    }

    switch (gear) {
      case 0:   // Neutral
        // pulse(S);
        break;

      case -1:  // Reverse
        pulse(L);
        pulse(L);
        break;

      case 1:
        pulse(S);
        break;

      case 2:
        pulse(S);
        pulse(S);
        break;

      case 3:   // L-S
        pulse(L);
        pulse(S);
        break;

      case 4:   // S-S-L
        pulse(S);
        pulse(S);
        pulse(L);
        break;

      case 5:   // S-L-S
        pulse(S);
        pulse(L);
        pulse(S);
        break;

      case 6:   // S-S-S
        pulse(S);
        pulse(S);
        pulse(S);
        break;

      case 7:   // L-L-S
        pulse(L);
        pulse(L);
        pulse(S);
        break;

      case 8:   // L-S-S-L
        pulse(L);
        pulse(S);
        pulse(S);
        pulse(L);
        break;

      default:
        pulse(S);
    }

    Vibration.vibrate(pattern: p);
  }


  void setAvailableGears(int count) {
    availableGears.value = count.clamp(1, 8);
  }

}
