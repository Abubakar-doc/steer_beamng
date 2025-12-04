import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SteeringService {
  final wheelDeg = 0.0.obs;
  final steer = 0.0.obs;

  final maxAngle = 450.0.obs; // now dynamic
  Timer? _returnTimer;

  double? _lastTouchAngle;
  bool _drag = false;

  final Function(double) send;
  final Function connectBeam;

  SteeringService(this.send, this.connectBeam);

  double _ang(Offset p, double s) {
    final c = Offset(s / 2, s / 2);
    final dx = p.dx - c.dx;
    final dy = p.dy - c.dy;
    var a = math.atan2(dy, dx) * 180 / math.pi + 90;
    if (a > 180) a -= 360;
    if (a < -180) a += 360;
    return a;
  }

  double _norm(double d) {
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  void onStart(DragStartDetails d, double s) {
    _returnTimer?.cancel();
    _drag = true;
    _lastTouchAngle = _ang(d.localPosition, s);
  }

  void onMove(DragUpdateDetails d, double s) {
    if (!_drag || _lastTouchAngle == null) return;

    final a = _ang(d.localPosition, s);
    final delta = _norm(a - _lastTouchAngle!);

    final next = (wheelDeg.value + delta).clamp(
      -maxAngle.value,
      maxAngle.value,
    );
    wheelDeg.value = next;
    steer.value = (next / maxAngle.value).clamp(-1, 1);

    send(steer.value);
    connectBeam();

    _lastTouchAngle = a;
  }

  void onEnd() {
    _drag = false;
    _lastTouchAngle = null;
    _return();
  }

  void _return() {
    final start = wheelDeg.value;
    const steps = 20;
    int i = 0;

    _returnTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      i++;
      final p = i / steps;
      final v = 1 - math.pow(1 - p, 2);
      final angle = start * (1 - v);

      wheelDeg.value = angle;
      steer.value = (angle / maxAngle.value).clamp(-1, 1);
      send(steer.value);

      if (i >= steps) {
        t.cancel();
        wheelDeg.value = 0;
        steer.value = 0;
        send(0);
      }
    });
  }
}
