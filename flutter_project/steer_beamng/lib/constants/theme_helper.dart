import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/responsive_helper.dart';

class AppTheme {

  // UNIVERSAL CONFIGURATION
  static double defaultPadding = ResponsiveHelper.isTablet(Get.context!) ? 40.0 : 20.0;
  static const int defaultViewTransitionDuration = 200;

  // LIGHT THEME CONFIGURATION
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // Overall light brightness8
    scaffoldBackgroundColor: Color(0xffFFFFFF), // Main background color for all screens

    // Color Scheme for light mode
    colorScheme: const ColorScheme.light(
      primary: Colors.orange,    // main accent color
      secondary: Colors.orange,  // Secondary accent
      surface: Colors.transparent,         // Card, AppBar, or elevated surfaces
      onPrimary: Colors.white,       // Text/icon color on top of primary
      onSecondary: Colors.white,     // Text/icon color on top of secondary
      onSurface: Colors.black,       // Text/icon color on top of surfaces
    ),
  );

  // DARK THEME CONFIGURATION
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Overall dark brightness
    scaffoldBackgroundColor: const Color(0xff131313), // Background for dark screens

    // Color Scheme for dark mode
    colorScheme: const ColorScheme.dark(
      primary: Colors.orange,    // Brand / main accent color
      secondary: Colors.orange,  // Secondary accent
      surface: Colors.transparent,    // Card & AppBar background
      onPrimary: Colors.white,       // Text/icon color on top of primary
      onSecondary: Colors.white,     // Text/icon color on top of secondary
      onSurface: Colors.white,       // Text/icon color on top of surfaces
    ),
  );
}


