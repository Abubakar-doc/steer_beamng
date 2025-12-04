import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class GearCountDropdown extends StatelessWidget {
  final ConsoleController controller;
  const GearCountDropdown(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<int>(
        dropdownColor: Colors.black,
        value: controller.selectedGearCount.value,
        items: controller.gearOptions
            .map(
              (g) => DropdownMenuItem(
            value: g,
            child: Text(
              "$g Gears + R",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
            .toList(),
        onChanged: (v) {
          if (v != null) controller.setGearCount(v);
        },
      );
    });
  }
}
