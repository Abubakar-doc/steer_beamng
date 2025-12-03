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
  final pedal = 0.0.obs; // -1 = full brake, 0 = neutral, 1 = full accel

  final vjoyConnected = false.obs;
  final beamConnected = false.obs;

  final double maxVisualAngle = 360.0; // 2 full turns
  Timer? _returnTimer;

  double? _lastTouchAngle;
  bool _isDragging = false;

  Socket? vjoySocket;
  Socket? beamSocket;

  // send throttling
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

  // single throttled send for both bridges
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
      vjoySocket!.write("$safe\n");
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

  // ---------------- gesture handlers ----------------
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

  // ---------------- return to center ----------------
  void startReturnToCenter() {
    _returnTimer?.cancel();

    final startAngle = wheelDeg.value;
    const int steps = 20;
    const duration = Duration(milliseconds: 400);
    final stepDuration = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );

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

  void onPedalChanged(double v) {
    pedal.value = v;

    final throttle = v > 0 ? v : 0.0;
    final brake    = v < 0 ? -v : 0.0;

    // TODO: send to vJoy/BeamNG
    // print('thr=$throttle brk=$brake');
  }
}
