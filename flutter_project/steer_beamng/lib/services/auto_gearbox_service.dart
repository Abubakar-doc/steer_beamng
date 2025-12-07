import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoGearboxService {
  final currentGear = "N".obs;
  final Function(String) sendAutoGear;

  Offset fingerStart = Offset.zero;
  Offset knobStart = Offset.zero;
  Offset dragOffset = Offset.zero;
  final visualOffset = Offset.zero.obs;

  AutoGearboxService(this.sendAutoGear);

  // Gears top → bottom
  final List<String> gears = ["P", "R", "N", "D", "S"];

  // -------------------------
  // START DRAG (exact same logic as manual)
  // -------------------------
  void startDrag(Offset finger, double height) {
    fingerStart = finger;
    knobStart = getKnobPos(height);      // real knob world pos
    dragOffset = fingerStart - knobStart; // make knob stick
  }

  // -------------------------
  // UPDATE DRAG
  // -------------------------
  void updateDrag(Offset finger, double height) {
    visualOffset.value = finger - dragOffset;

    Offset simulated = finger - dragOffset;
    String g = _detectGear(simulated.dy, height);

    if (g != currentGear.value) {
      currentGear.value = g;
      sendAutoGear(g);
    }
  }

  // -------------------------
  // END DRAG
  // -------------------------
  void endDrag(double height) {
    visualOffset.value = Offset.zero;
    sendAutoGear(currentGear.value);
  }

  // -------------------------
  // Get knob position
  // -------------------------
  Offset getKnobPos(double height) {
    double slot = height / gears.length;
    int index = gears.indexOf(currentGear.value);

    return Offset(40, slot * index + slot / 2);
  }

  // -------------------------
  // Detect gear (snap to nearest)
  // -------------------------
  String _detectGear(double y, double height) {
    double slot = height / gears.length;
    int index = (y / slot).round().clamp(0, gears.length - 1);
    return gears[index];
  }
}
