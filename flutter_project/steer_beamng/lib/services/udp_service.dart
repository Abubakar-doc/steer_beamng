import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

class UdpService {
  RawDatagramSocket? socket;

  final connected = false.obs; // local socket open
  final serverAlive = false.obs; // remote server alive
  final pingMs = 0.0.obs;

  final void Function(String line) onData;

  InternetAddress serverIp = InternetAddress("192.168.1.116");
  int serverPort = 5000;

  DateTime? _lastPingSend;
  DateTime? _lastPong;
  Timer? _pingTimer;

  UdpService({required this.onData});

  Future<void> connect() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      connected.value = true;

      print("🔌 UDP ready");

      socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket!.receive();
          if (datagram == null) return;

          final msg = utf8.decode(datagram.data).trim();

          if (msg == "PONG") {
            _lastPong = DateTime.now();
            serverAlive.value = true;

            pingMs.value = DateTime.now()
                .difference(_lastPingSend!)
                .inMilliseconds
                .toDouble();
            return;
          }

          onData(msg);
        }
      });

      _startPing();
    } catch (e) {
      connected.value = false;
      print("❌ UDP Init Failed: $e");
    }
  }

  void send(String msg) {
    socket?.send(utf8.encode(msg), serverIp, serverPort);
  }

  void _startPing() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (socket == null) return;

      _lastPingSend = DateTime.now();
      send("PING");

      // server timeout detection
      if (_lastPong != null &&
          DateTime.now().difference(_lastPong!).inMilliseconds > 2000) {
        serverAlive.value = false;
      }
    });
  }

  void dispose() {
    _pingTimer?.cancel();
    serverAlive.value = false;
    connected.value = false;
    socket?.close();
  }
}
