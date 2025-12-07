import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

Widget appBtn({
  required String label,
  required String asset,
  required double iconSize,
  required double fontSize,
  required VoidCallback onPressed,
  VoidCallback? onHoldStart,
  VoidCallback? onHoldEnd,
  bool compact = false,
}) {
  bool held = false;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,

    onLongPressStart: (_) {
      held = true;
      if (onHoldStart != null) onHoldStart!();
    },

    onLongPressEnd: (_) {
      if (onHoldEnd != null) onHoldEnd!();
      // small delay then reset
      Future.delayed(Duration(milliseconds: 50), () => held = false);
    },

    onTap: () {
      if (!held) {
        onPressed();
      }
    },

    child: Container(
      padding: EdgeInsets.all(compact ? 6 : 0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: compact
          ? SvgPicture.asset(
        asset,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            asset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
