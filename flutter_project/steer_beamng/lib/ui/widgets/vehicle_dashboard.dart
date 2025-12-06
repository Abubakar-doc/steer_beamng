import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/assets_helper.dart';

import 'app_button.dart';

class VehicleDashboard extends StatelessWidget {
  final void Function(String action) onPressed;
  const VehicleDashboard(this.onPressed, {super.key});

  Widget btn(String label, String assetPath, double iconSize, double fontSize) {
    return InkWell(
      onTap: () => onPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            SizedBox(height: fontSize * 0.3),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final h = Get.height;

    final size = (w < h ? w : h) * 0.40;
    final iconSize = size * 0.11;
    final fontSize = size * 0.06;

    return SizedBox(
      width: size,
      height: size,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          appBtn(label: "Fog",  asset: AssetsHelper.fog,  iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Fog")),
          appBtn(label: "Head", asset: AssetsHelper.headlight, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Head")),
          appBtn(label: "Horn", asset: AssetsHelper.horn, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Horn")),
          appBtn(label: "Left", asset: AssetsHelper.left, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Left")),
          appBtn(label: "Haz",  asset: AssetsHelper.hazard, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Haz")),
          appBtn(label: "Right",asset: AssetsHelper.right, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Right")),
          appBtn(label: "Diff", asset: AssetsHelper.diff, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("Diff")),
          appBtn(label: "ESC",  asset: AssetsHelper.esc, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("ESC")),
          appBtn(label: "4WD",  asset: AssetsHelper.w4d, iconSize: iconSize, fontSize: fontSize, onPressed: () => onPressed("4WD")),
        ],
      ),
    );
  }
}
