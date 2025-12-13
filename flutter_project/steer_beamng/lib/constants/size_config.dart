import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double scaleWidth;
  static late double scaleHeight;
  static bool isTablet = false;

  // Figma design size mobile
  static const double figmaPhoneWidth = 440;
  static const double figmaPhoneHeight = 956;

  // Figma design size tablet
  static const double figmaTabletWidth = 1024;
  static const double figmaTabletHeight = 1366;

  static void init(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    // Tablet check (can adjust threshold as needed)
    isTablet = screenWidth > 600;

    if (isTablet) {
      scaleWidth = screenWidth / figmaTabletWidth;
      scaleHeight = screenHeight / figmaTabletHeight;
    } else {
      scaleWidth = screenWidth / figmaPhoneWidth;
      scaleHeight = screenHeight / figmaPhoneHeight;
    }
  }

  // Width adjust
  static double w(double width) => width * scaleWidth;

  // Height adjust
  static double h(double height) => height * scaleHeight;

  // Font size adjust
  static double sp(double fontSize) => fontSize * scaleWidth;
}