import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CamBtn extends StatelessWidget {
  final String asset;
  final double iconSize;
  final VoidCallback onTap;

  const CamBtn({
    super.key,
    required this.asset,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(6),
        ),
        child: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
