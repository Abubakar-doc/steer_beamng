import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Socket? vjoySocket;
Socket? beamSocket;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SteeringApp());
}

class SteeringApp extends StatefulWidget {
  const SteeringApp({super.key});

  @override
  State<SteeringApp> createState() => _SteeringAppState();
}

class _SteeringAppState extends State<SteeringApp> {
  double wheelDeg = 0;
  double steeringValue = 0;
  double lastAngle = 0;
  bool vjoyConnected = false;
  bool beamConnected = false;

  final double maxVisualAngle = 360.0; // 2 full turns lock-to-lock
  Timer? _returnTimer;

  @override
  void initState() {
    super.initState();
    connectVJoyServer();
    connectBeamNG();
  }

  // ------------------------------------------------------
  // CONNECT TO PC vJoy SERVER
  // ------------------------------------------------------
  Future<void> connectVJoyServer() async {
    const pcIp = "192.168.1.116";
    const pcPort = 5000;

    print("Connecting to vJoy server at $pcIp:$pcPort...");

    try {
      vjoySocket =
      await Socket.connect(pcIp, pcPort, timeout: const Duration(seconds: 2));
      print("Connected to vJoy server!");
      vjoyConnected = true;
      setState(() {});

      vjoySocket!.listen(
            (data) => print("Server: ${String.fromCharCodes(data)}"),
        onDone: () {
          print("vJoy server closed.");
          vjoyConnected = false;
          vjoySocket = null;
          setState(() {});
        },
        onError: (e) {
          print("vJoy error: $e");
          vjoyConnected = false;
          vjoySocket = null;
          setState(() {});
        },
      );
    } catch (e) {
      print("Connect failed: $e");
      vjoyConnected = false;
      setState(() {});
    }
  }

  // ------------------------------------------------------
  // SEND STEERING TO PC
  // ------------------------------------------------------
  void sendToVJoy(double value) {
    if (vjoySocket != null) {
      final safe = value.toStringAsFixed(6);
      vjoySocket!.write("$safe\n");
    }
  }

  // ------------------------------------------------------
  // CONNECT TO BEAMNG (optional)
  // ------------------------------------------------------
  void connectBeamNG() async {
    print("Connecting to BeamNG (127.0.0.1:4444)...");

    try {
      beamSocket = await Socket.connect('127.0.0.1', 4444,
          timeout: const Duration(seconds: 2));
      print("CONNECTED to BeamNG!");
      beamConnected = true;
      setState(() {});

      beamSocket!.listen(
            (data) => print("BeamNG: ${String.fromCharCodes(data)}"),
        onDone: () {
          print("BeamNG closed");
          beamConnected = false;
          setState(() {});
        },
        onError: (e) {
          print("BeamNG error: $e");
          beamConnected = false;
          setState(() {});
        },
      );
    } catch (e) {
      print("BeamNG connection FAILED: $e");
      beamConnected = false;
      setState(() {});
    }
  }

  // ------------------------------------------------------
  // SEND TO BEAMNG
  // ------------------------------------------------------
  void sendSteer(double value) {
    if (beamSocket != null) {
      beamSocket!.write('{"steering": $value}\n');
    }
  }

  // ------------------------------------------------------
  // UPDATE STEERING (2 turns, hard-limited)
  // ------------------------------------------------------
  void _updateSteering(Offset pos, double size) {
    // stop any return-to-center animation while user is touching
    _returnTimer?.cancel();
    _returnTimer = null;

    final center = Offset(size / 2, size / 2);

    double dx = pos.dx - center.dx;
    double dy = pos.dy - center.dy;

    double angle = math.atan2(dy, dx) * 180 / math.pi + 90;

    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;

    double delta = angle - lastAngle;

    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;

    double newAngle =
    (lastAngle + delta).clamp(-maxVisualAngle, maxVisualAngle);

    lastAngle = newAngle;

    double steering = (newAngle / maxVisualAngle).clamp(-1.0, 1.0);

    setState(() {
      wheelDeg = newAngle;
      steeringValue = steering;
      sendToVJoy(steeringValue);
      sendSteer(steeringValue);
    });
  }

  // ------------------------------------------------------
  // SMOOTH RETURN TO CENTER
  // ------------------------------------------------------
  void _startReturnToCenter() {
    _returnTimer?.cancel();

    final startAngle = wheelDeg;
    final int steps = 25; // more steps = smoother
    const duration = Duration(milliseconds: 200);
    final stepDuration =
    Duration(milliseconds: duration.inMilliseconds ~/ steps);

    int currentStep = 0;

    _returnTimer = Timer.periodic(stepDuration, (t) {
      currentStep++;
      final tNorm = currentStep / steps; // 0..1

      // ease out (fast at start, slow near center)
      final ease = 1.0 - math.pow(1.0 - tNorm, 2);

      final angle = startAngle * (1.0 - ease);

      final steering = (angle / maxVisualAngle).clamp(-1.0, 1.0);

      setState(() {
        wheelDeg = angle;
        lastAngle = angle;
        steeringValue = steering;
        sendToVJoy(steeringValue);
        sendSteer(steeringValue);
      });

      if (currentStep >= steps) {
        t.cancel();
        _returnTimer = null;
        setState(() {
          wheelDeg = 0;
          lastAngle = 0;
          steeringValue = 0;
          sendToVJoy(0);
          sendSteer(0);
        });
      }
    });
  }

  // ------------------------------------------------------
  // UI
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final size =
                math.min(constraints.maxWidth, constraints.maxHeight) * 0.6;

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // RECONNECT BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                            vjoyConnected ? Colors.green : Colors.red),
                        onPressed: () => connectVJoyServer(),
                        child: const Text("Reconnect vJoy"),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                            beamConnected ? Colors.green : Colors.red),
                        onPressed: () => connectBeamNG(),
                        child: const Text("Reconnect BeamNG"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // STEERING WHEEL
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => _updateSteering(d.localPosition, size),
                    onPanUpdate: (d) => _updateSteering(d.localPosition, size),
                    onPanEnd: (_) {
                      _startReturnToCenter();
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: size,
                      height: size,
                      child: Transform.rotate(
                        angle: wheelDeg * math.pi / 180,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                            Border.all(width: 8, color: Colors.white),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: size * 0.3,
                                height: size * 0.3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                ),
                              ),
                              Positioned(
                                top: size * 0.08,
                                child: Container(
                                  width: size * 0.1,
                                  height: size * 0.3,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Angle: ${wheelDeg.toStringAsFixed(1)}°",
                    style:
                    const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  Text(
                    "Steering: ${steeringValue.toStringAsFixed(3)}",
                    style: const TextStyle(
                        color: Colors.greenAccent, fontSize: 22),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
