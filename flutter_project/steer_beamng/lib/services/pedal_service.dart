import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PedalService {
  final RxDouble pedal; // comes from controller
  Timer? _ret;

  final Function(double, double) send;
  final Function connectBeam;

  PedalService(this.pedal, this.send, this.connectBeam);

  void _apply(double v) {
    pedal.value = v.clamp(-1.0, 1.0);

    final throttle = pedal.value > 0 ? pedal.value : 0.0;
    final brake    = pedal.value < 0 ? -pedal.value : 0.0;

    send(throttle, brake);
    connectBeam();
  }

  void onStart() {
    _ret?.cancel();
    _ret = null;
  }

  void onMove(DragUpdateDetails d, double height) {
    final y    = d.localPosition.dy.clamp(0, height);
    final half = height / 2;
    final v    = (half - y) / half; // top=+1, mid=0, bottom=-1
    _apply(v);
  }

  void onEnd() {
    _startReturn();
  }

  void _startReturn() {
    _ret?.cancel();

    final start = pedal.value;
    if (start == 0) return;

    const duration = Duration(milliseconds: 120);
    const steps = 20;
    final stepDuration =
    Duration(milliseconds: duration.inMilliseconds ~/ steps);

    int i = 0;
    _ret = Timer.periodic(stepDuration, (t) {
      i++;
      final tNorm = i / steps;
      final ease = 1.0 - math.pow(1.0 - tNorm, 2);
      final v = start * (1.0 - ease);

      _apply(v.toDouble());

      if (i >= steps) {
        t.cancel();
        _ret = null;
        _apply(0.0);
      }
    });
  }
}
