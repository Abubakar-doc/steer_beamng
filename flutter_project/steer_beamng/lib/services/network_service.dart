import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveredServer {
  final InternetAddress ip;
  final String name;

  DiscoveredServer(this.ip, this.name);
}

class NetworkService {
  RawDatagramSocket? socket;

  final connected = false.obs;
  final serverAlive = false.obs;
  final pingMs = 0.0.obs;

  final discoveredServers = <DiscoveredServer>[].obs;

  final Rxn<InternetAddress> currentServerIp = Rxn<InternetAddress>();
  final favouriteIp = RxnString();

  final void Function(String line) onData;

  int serverPort = 5000;

  DateTime? _lastPingSend;
  DateTime? _lastPong;
  Timer? _pingTimer;

  static const _favKey = "favorite_server";

  NetworkService({required this.onData});

  Future<void> start() async {
    socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: true,
    );

    socket!.broadcastEnabled = true;
    connected.value = true;

    await loadFavourite();

    socket!.listen((event) async {
      if (event != RawSocketEvent.read) return;

      final d = socket!.receive();
      if (d == null) return;

      final msg = utf8.decode(d.data).trim();

      // SERVER_HERE:PCNAME
      if (msg.startsWith("SERVER_HERE")) {
        final parts = msg.split(":");
        final name = parts.length > 1 ? parts[1] : "Unknown PC";

        if (!discoveredServers.any((e) => e.ip.address == d.address.address)) {
          discoveredServers.add(DiscoveredServer(d.address, name));
        }

        if (favouriteIp.value == d.address.address &&
            currentServerIp.value == null) {
          connectToServer(d.address);
        }
        return;
      }

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
    });

    _discover();
  }

  void _discover() {
    socket?.send(
      utf8.encode("DISCOVER_SERVER"),
      InternetAddress("255.255.255.255"),
      serverPort,
    );
  }

  Future<void> connectToServer(InternetAddress ip) async {
    currentServerIp.value = ip;
    await toggleFavourite(ip.address);
    _startPing();
  }

  void send(String msg) {
    if (currentServerIp.value == null) return;
    socket?.send(utf8.encode(msg), currentServerIp.value!, serverPort);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (currentServerIp.value == null) return;
      _lastPingSend = DateTime.now();
      send("PING");

      if (_lastPong != null &&
          DateTime.now().difference(_lastPong!).inMilliseconds > 2000) {
        serverAlive.value = false;
      }
    });
  }

  Future<void> loadFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    favouriteIp.value = prefs.getString(_favKey);
  }

  Future<void> toggleFavourite(String ip) async {
    final prefs = await SharedPreferences.getInstance();

    if (favouriteIp.value == ip) {
      await prefs.remove(_favKey);
      favouriteIp.value = null;
    } else {
      await prefs.setString(_favKey, ip);
      favouriteIp.value = ip;
    }
  }

  void disconnect() {
    _pingTimer?.cancel();
    currentServerIp.value = null;
    serverAlive.value = false;
  }

  void dispose() {
    _pingTimer?.cancel();
    socket?.close();
    connected.value = false;
    serverAlive.value = false;
  }

  DiscoveredServer? get connectedServer {
    final ip = currentServerIp.value;
    if (ip == null) return null;

    return discoveredServers.firstWhereOrNull(
          (s) => s.ip.address == ip.address,
    );
  }

}
