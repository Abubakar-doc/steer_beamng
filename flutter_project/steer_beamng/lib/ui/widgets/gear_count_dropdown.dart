import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class GearCountDropdown extends StatelessWidget {
  final ConsoleController controller;
  const GearCountDropdown(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<dynamic>(
        dropdownColor: Colors.black,
        value: controller.useAutoGearbox.value
            ? "Auto"
            : controller.selectedGearCount.value,
        items: controller.gearOptions.map((g) {
          return DropdownMenuItem(
            value: g,
            child: Text(
              g == "Auto"
                  ? "Automatic"
                  : "$g-Manual",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v == null) return;

          if (v == "Auto") {
            controller.useAutoGearbox.value = true;
          } else {
            controller.useAutoGearbox.value = false;
            controller.setGearCount(v as int);
          }
        },
      );
    });
  }
}
