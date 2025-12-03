import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SteeringController extends GetxController {
  // reactive state
  final wheelDeg = 0.0.obs;
  final steeringValue = 0.0.obs;
  final lastAngle = 0.0.obs;

  // -1 = full brake, 0 = neutral, 1 = full accel
  final pedal = 0.0.obs;

  final vjoyConnected = false.obs;
  final beamConnected = false.obs;

  final double maxVisualAngle = 360.0; // 2 full turns
  Timer? _returnTimer;
  Timer? _pedalReturnTimer;

  double? _lastTouchAngle;
  bool _isDragging = false;

  Socket? vjoySocket;
  Socket? beamSocket;

  // send throttling (steering)
  double _lastSentSteer = 0.0;
  DateTime _lastSendTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _minSendIntervalMs = 10; // ~100 Hz
  static const double _eps = 0.002;

  @override
  void onInit() {
    super.onInit();
    connectVJoyServer();
    connectBeamNG();
  }

  @override
  void onClose() {
    _returnTimer?.cancel();
    _pedalReturnTimer?.cancel();
    vjoySocket?.destroy();
    beamSocket?.destroy();
    super.onClose();
  }

  // ---------------- vJoy ----------------
  Future<void> connectVJoyServer() async {
    const pcIp = "192.168.1.116";
    const pcPort = 5000;

    try {
      vjoySocket = await Socket.connect(
        pcIp,
        pcPort,
        timeout: const Duration(seconds: 2),
      );

      vjoySocket!.setOption(SocketOption.tcpNoDelay, true);
      vjoyConnected.value = true;

      vjoySocket!.listen(
            (data) {},
        onDone: () {
          vjoyConnected.value = false;
          vjoySocket = null;
        },
        onError: (e) {
          vjoyConnected.value = false;
          vjoySocket = null;
        },
      );
    } catch (e) {
      vjoyConnected.value = false;
    }
  }

  // ---------------- BeamNG ----------------
  Future<void> connectBeamNG() async {
    try {
      beamSocket = await Socket.connect(
        '127.0.0.1',
        4444,
        timeout: const Duration(seconds: 2),
      );

      beamSocket!.setOption(SocketOption.tcpNoDelay, true);
      beamConnected.value = true;

      beamSocket!.listen(
            (data) {},
        onDone: () {
          beamConnected.value = false;
          beamSocket = null;
        },
        onError: (e) {
          beamConnected.value = false;
          beamSocket = null;
        },
      );
    } catch (e) {
      beamConnected.value = false;
    }
  }

  // ---------------- steering send (throttled) ----------------
  void _sendSteering(double value) {
    final now = DateTime.now();
    if ((value - _lastSentSteer).abs() < _eps &&
        now.difference(_lastSendTime).inMilliseconds < _minSendIntervalMs) {
      return;
    }

    _lastSentSteer = value;
    _lastSendTime = now;

    if (vjoySocket != null) {
      final safe = value.toStringAsFixed(6);
      vjoySocket!.write("$safe\n"); // plain line = steering for your C# server
    }
    if (beamSocket != null) {
      beamSocket!.write('{"steering": $value}\n');
    }
  }

  // ---------------- angle helpers ----------------
  double angleFromCenter(Offset pos, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;

    double angle = math.atan2(dy, dx) * 180 / math.pi + 90;
    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;
    return angle;
  }

  double normalizeDelta(double delta) {
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return delta;
  }

  // ---------------- steering gesture handlers ----------------
  void onPanStart(DragStartDetails d, double size) {
    _returnTimer?.cancel();
    _returnTimer = null;

    _isDragging = true;
    _lastTouchAngle = angleFromCenter(d.localPosition, size);
  }

  void onPanUpdate(DragUpdateDetails d, double size) {
    if (!_isDragging || _lastTouchAngle == null) return;

    final currentTouchAngle = angleFromCenter(d.localPosition, size);
    double delta = normalizeDelta(currentTouchAngle - _lastTouchAngle!);

    double candidate = wheelDeg.value + delta;
    double clamped = candidate.clamp(-maxVisualAngle, maxVisualAngle);

    bool pushingBeyondMax =
        (wheelDeg.value >= maxVisualAngle && delta > 0) ||
            (wheelDeg.value <= -maxVisualAngle && delta < 0);

    if (!pushingBeyondMax) {
      wheelDeg.value = clamped;
      lastAngle.value = wheelDeg.value;
      final s = (wheelDeg.value / maxVisualAngle).clamp(-1.0, 1.0);
      steeringValue.value = s;

      _sendSteering(s);
    }

    _lastTouchAngle = currentTouchAngle;
  }

  void onPanEnd() {
    _isDragging = false;
    _lastTouchAngle = null;
    startReturnToCenter();
  }

  // ---------------- steering return to center ----------------
  void startReturnToCenter() {
    _returnTimer?.cancel();

    final startAngle = wheelDeg.value;
    const int steps = 20;
    const duration = Duration(milliseconds: 400);
    final stepDuration =
    Duration(milliseconds: duration.inMilliseconds ~/ steps);

    int currentStep = 0;

    _returnTimer = Timer.periodic(stepDuration, (t) {
      currentStep++;
      final tNorm = currentStep / steps;
      final ease = 1.0 - math.pow(1.0 - tNorm, 2);

      final angle = startAngle * (1.0 - ease);
      final steering = (angle / maxVisualAngle).clamp(-1.0, 1.0);

      wheelDeg.value = angle;
      lastAngle.value = angle;
      steeringValue.value = steering;

      _sendSteering(steering);

      if (currentStep >= steps) {
        t.cancel();
        _returnTimer = null;

        wheelDeg.value = 0;
        lastAngle.value = 0;
        steeringValue.value = 0;

        _sendSteering(0);
      }
    });
  }

  // ==========================================================
  //                        PEDAL
  // ==========================================================

  // main pedal apply + SEND to vJoy / Beam
  void _applyPedal(double v) {
    pedal.value = v.clamp(-1.0, 1.0);

    final throttle = pedal.value > 0 ? pedal.value : 0.0;
    final brake    = pedal.value < 0 ? -pedal.value : 0.0;

    _sendPedal(throttle, brake);

    if (beamSocket != null) {
      beamSocket!.write(
        '{"throttle": $throttle, "brake": $brake}\n',
      );
    }
  }

  // optional direct change (if ever used with a Slider)
  void onPedalChanged(double v) {
    _applyPedal(v);
  }

  void onPedalPanStart() {
    _pedalReturnTimer?.cancel();
    _pedalReturnTimer = null;
  }

  void onPedalPanUpdate(DragUpdateDetails d, double height) {
    final y = d.localPosition.dy.clamp(0, height);
    final half = height / 2;
    // map: top = +1, middle = 0, bottom = -1
    final v = (half - y) / half;
    _applyPedal(v);
  }

  void onPedalPanEnd() {
    _startPedalReturn();
  }

  void _startPedalReturn() {
    _pedalReturnTimer?.cancel();

    final start = pedal.value;
    if (start == 0) return;

    const duration = Duration(milliseconds: 120);
    const steps = 20;
    final stepDuration =
    Duration(milliseconds: duration.inMilliseconds ~/ steps);

    int i = 0;
    _pedalReturnTimer = Timer.periodic(stepDuration, (t) {
      i++;
      final tNorm = i / steps;
      final ease = 1.0 - math.pow(1.0 - tNorm, 2);
      final v = start * (1.0 - ease);

      _applyPedal(v.toDouble());

      if (i >= steps) {
        t.cancel();
        _pedalReturnTimer = null;
        _applyPedal(0.0);
      }
    });
  }

  // send pedal to vJoy: THR:x / BRK:x (0..1)
  void _sendPedal(double throttle, double brake) {
    if (vjoySocket == null) return;

    final thr = throttle.clamp(0.0, 1.0).toStringAsFixed(3);
    final brk = brake.clamp(0.0, 1.0).toStringAsFixed(3);

    vjoySocket!.write("THR:$thr\n");
    vjoySocket!.write("BRK:$brk\n");
  }
}
