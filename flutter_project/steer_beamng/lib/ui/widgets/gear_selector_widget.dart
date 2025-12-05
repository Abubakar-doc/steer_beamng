import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/console_controller.dart';
import 'package:steer_beamng/ui/widgets/auto_gearbox_widget.dart';

import 'gear_count_dropdown.dart';

class GearSelectorWidget extends StatelessWidget {
  final ConsoleController controller;
  const GearSelectorWidget(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GearCountDropdown(controller),
      ],
    );
  }
}

