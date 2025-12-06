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
  bool didHold = false;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,

    onTapDown: (_) {
      didHold = false;
      if (onHoldStart != null) {
        didHold = true;
        onHoldStart!();
      }
    },

    onTapUp: (_) {
      if (didHold && onHoldEnd != null) {
        onHoldEnd!();
        return; // STOP here → do NOT trigger onTap
      }
    },

    onTapCancel: () {
      if (didHold && onHoldEnd != null) {
        onHoldEnd!();
      }
    },

    onTap: () {
      if (!didHold) {
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
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            asset,
            width: iconSize,
            height: iconSize,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
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
