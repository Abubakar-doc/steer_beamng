import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

class TcpService {
  Socket? socket;

  final connected = false.obs;
  final pingMs = 0.0.obs;

  DateTime? _lastPingSend;
  Timer? _pingTimer;

  // Callbacks
  final void Function(String line) onData;

  TcpService({required this.onData});

  // --------------------------
  // CONNECT
  // --------------------------
  Future<void> connect() async {
    try {
      socket = await Socket.connect("192.168.1.116", 5000);
      socket!.setOption(SocketOption.tcpNoDelay, true);

      connected.value = true;
      print("🔌 TCP connected");

      _startPing();

      socket!.listen(
        _handleData,
        onError: (e) {
          print("TCP ERROR: $e");
          connected.value = false;
        },
        onDone: () {
          print("TCP CLOSED");
          connected.value = false;
        },
      );
    } catch (e) {
      connected.value = false;
      print("❌ TCP Connect Failed: $e");
    }
  }

  // --------------------------
  // PROCESS SERVER DATA
  // --------------------------
  void _handleData(Uint8List raw) {
    final decoded = utf8.decode(raw).trim();

    for (final line in decoded.split("\n")) {
      if (line.isEmpty) continue;

      if (line == "PONG") {
        pingMs.value = DateTime.now()
            .difference(_lastPingSend!)
            .inMilliseconds
            .toDouble();
        continue;
      }

      onData(line);
    }
  }

  // --------------------------
  // SEND
  // --------------------------
  void send(String msg) {
    socket?.write("$msg\n");
  }

  // --------------------------
  // PING LOOP
  // --------------------------
  void _startPing() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (socket == null) return;
      _lastPingSend = DateTime.now();
      socket!.write("PING\n");
    });
  }

  // --------------------------
  // DISCONNECT
  // --------------------------
  void dispose() {
    _pingTimer?.cancel();
    socket?.destroy();
  }
}
