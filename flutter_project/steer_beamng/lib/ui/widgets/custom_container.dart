import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/controllers/theme_controller.dart';

class CustomContainer extends StatelessWidget {
  final Shape shape;
  final double size;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool tappable;
  final VoidCallback? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomContainer({
    super.key,
    required this.shape,
    this.size = 140,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.tappable = false,
    this.onTap,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final isDark = themeController.isDarkMode.value;

    final resolvedBorderColor =
        borderColor ?? (!isDark ? const Color(0xffc4c4c4cc) : Colors.white);

    switch (shape) {
      // -------------------------------
      // Square Container
      // -------------------------------
      case Shape.square:
        final container = Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: resolvedBorderColor, width: 1),
          ),
          child: Padding(padding: padding, child: child),
        );

        return tappable
            ? Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: onTap,
                  child: container,
                ),
              )
            : container;

      // -------------------------------
      // Circle Container
      // -------------------------------
      case Shape.circle:
        return Obx(() {
          final isLight = !themeController.isDarkMode.value;

          final circle = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: resolvedBorderColor, width: 1),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(child: child),
          );

          return tappable
              ? Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    child: circle,
                  ),
                )
              : circle;
        });
    }
  }
}

enum Shape { square, circle }
