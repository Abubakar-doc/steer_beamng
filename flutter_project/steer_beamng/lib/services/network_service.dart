import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveredServer {
  final InternetAddress ip;
  final String name;
  final DateTime lastSeen;

  DiscoveredServer(this.ip, this.name, this.lastSeen);

  DiscoveredServer copyWith({DateTime? lastSeen}) =>
      DiscoveredServer(ip, name, lastSeen ?? this.lastSeen);
}

class NetworkService {
  RawDatagramSocket? socket;

  final connected = false.obs;
  final serverAlive = false.obs;
  final pingMs = 0.0.obs;

  final discoveredServers = <DiscoveredServer>[].obs;

  final Rxn<InternetAddress> currentServerIp = Rxn();
  final favouriteIp = RxnString();

  final void Function(String line) onData;

  int serverPort = 5000;

  DateTime? _lastPingSend;
  DateTime? _lastPong;

  Timer? _pingTimer;
  Timer? _discoveryTimer;
  Timer? _cleanupTimer;

  static const _favKey = "favorite_server";

  NetworkService({required this.onData});

  // ---------------- START ----------------
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

    socket!.listen((event) {
      if (event != RawSocketEvent.read) return;

      final d = socket!.receive();
      if (d == null) return;

      final msg = utf8.decode(d.data).trim();

      // ---------- DISCOVERY ----------
      if (msg.startsWith("SERVER_HERE")) {
        final parts = msg.split(":");
        final name = parts.length > 1 ? parts[1] : "Unknown PC";
        final ip = d.address;

        final index = discoveredServers
            .indexWhere((s) => s.ip.address == ip.address);

        if (index != -1) {
          discoveredServers[index] =
              discoveredServers[index].copyWith(
                lastSeen: DateTime.now(),
              );
        } else {
          discoveredServers.add(
            DiscoveredServer(ip, name, DateTime.now()),
          );
        }

        if (favouriteIp.value == ip.address &&
            currentServerIp.value == null) {
          connectToServer(ip);
        }
        return;
      }

      // ---------- HEARTBEAT ----------
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
    _startDiscoveryLoop();
    _startCleanupLoop();
  }

  // ---------------- DISCOVERY ----------------
  void _discover() {
    socket?.send(
      utf8.encode("DISCOVER_SERVER"),
      InternetAddress("255.255.255.255"),
      serverPort,
    );
  }

  void _startDiscoveryLoop() {
    _discoveryTimer?.cancel();
    _discoveryTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _discover());
  }

  void _startCleanupLoop() {
    _cleanupTimer?.cancel();
    _cleanupTimer =
        Timer.periodic(const Duration(seconds: 2), (_) {
          final now = DateTime.now();
          discoveredServers.removeWhere(
                (s) => now.difference(s.lastSeen).inSeconds > 5,
          );
        });
  }

  // ---------------- CONNECTION ----------------
  Future<void> connectToServer(InternetAddress ip) async {
    currentServerIp.value = ip;
    await toggleFavourite(ip.address);
    _startPing();
  }

  void disconnect() {
    _pingTimer?.cancel();
    currentServerIp.value = null;
    serverAlive.value = false;
  }

  void send(String msg) {
    if (currentServerIp.value == null) return;
    socket?.send(utf8.encode(msg), currentServerIp.value!, serverPort);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (currentServerIp.value == null) return;

          _lastPingSend = DateTime.now();
          send("PING");

          if (_lastPong != null &&
              DateTime.now()
                  .difference(_lastPong!)
                  .inMilliseconds >
                  2000) {
            serverAlive.value = false;
          }
        });
  }

  // ---------------- FAVOURITE ----------------
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

  // ---------------- HELPERS ----------------
  DiscoveredServer? get connectedServer {
    final ip = currentServerIp.value;
    if (ip == null) return null;

    return discoveredServers.firstWhereOrNull(
          (s) => s.ip.address == ip.address,
    );
  }

  void refreshDiscovery() {
    discoveredServers.clear();
    _discover();
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _discoveryTimer?.cancel();
    _pingTimer?.cancel();
    socket?.close();
    connected.value = false;
    serverAlive.value = false;
  }
}
