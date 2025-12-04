import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';

class SteeringAngleDropdown extends StatelessWidget {
  final ConsoleController controller;
  const SteeringAngleDropdown(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownButton<double>(
        dropdownColor: Colors.black,
        value: controller.selectedAngle.value,
        items: controller.angles
            .map(
              (a) => DropdownMenuItem(
            value: a,
            child: Text(
              "${a.toInt()}°",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        )
            .toList(),
        onChanged: (v) {
          if (v != null) controller.setSteeringAngle(v);
        },
      );
    });
  }
}
