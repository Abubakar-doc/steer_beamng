import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 20),
                  const Text("Settings", style: TextStyle(fontSize: 22)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Available Connections",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    c.refresh();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: c.servers.isEmpty
                      ? ListView(
                          children: const [
                            Center(child: Text("Nothing to show.")),
                          ],
                        )
                      : ListView.separated(
                          itemCount: c.servers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final s = c.servers[i];

                            final isFav = c.favourite == s.ip.address;
                            final isConnected =
                                c.connected?.address == s.ip.address;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  isConnected ? Icons.wifi : Icons.computer,
                                  color: isConnected ? Colors.green : null,
                                ),
                                title: Text(
                                  s.name,
                                  style: TextStyle(
                                    fontWeight: isFav
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  "${s.ip.address}${isConnected ? " • Connected" : ""}",
                                  style: TextStyle(
                                    color: isConnected
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isConnected)
                                      IconButton(
                                        icon: const Icon(Icons.link),
                                        onPressed: () => c.connect(s),
                                      ),
                                    if (isConnected)
                                      IconButton(
                                        icon: const Icon(Icons.link_off),
                                        onPressed: c.disconnect,
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color: isFav
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                      onPressed: () => c.toggleFavourite(s),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
