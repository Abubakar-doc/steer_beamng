import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponsiveHelper {
  static double deviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Extra small (tiny devices)
  static bool isVerySmallDevice(BuildContext context) {
    return deviceWidth(context) < 320;
  }

  // Small phones like iPhone SE, iPhone 7, etc.
  static bool isSmallDevice(BuildContext context) {
    return deviceWidth(context) <= 375;
  }

  // Medium phones like Pixel 4a, iPhone 11
  static bool isMediumDevice(BuildContext context) {
    double width = deviceWidth(context);
    return width >= 360 && width < 400;
  }

  // Normal size tablets (e.g., iPad Mini, Galaxy Tab A 8.0)
  static bool isNormalTablet(BuildContext context) {
    final width = deviceWidth(context);
    return width >= 600 && width < 900;
  }

  // Large phones like iPhone 13 Pro Max
  static bool isLargeDevice(BuildContext context) {
    return deviceWidth(context) >= 400;
  }

  // Tablet check (optional)
  static bool isTablet(BuildContext context) {
    final width = deviceWidth(context);
    return width >= 810;
  }

  // Large tablets (e.g., iPad Pro, Galaxy Tab S7+)
  static bool isLargeTablet(BuildContext context) {
    final width = deviceWidth(context);
    return width >= 900;
  }

  static bool isExtraLargeDevice(BuildContext context) {
    return deviceWidth(context) >= 1200;
  }

  static Future<void> setOrientation(BuildContext context) async {
    if (isTablet(context)) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
}
