import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/constants/responsive_helper.dart';
import 'package:steer_beamng/constants/url_constants.dart';
import 'package:steer_beamng/ui/widgets/custom_container.dart';
import 'package:url_launcher/url_launcher.dart';

class DialogUtils {
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String? svg,
    double? svgSize,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) async {
    return Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: Get.width * 0.35),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: Get.width * 0.35,
            ),
            child: CustomContainer(
              borderColor: Get.theme.colorScheme.primary,
              shape: Shape.square,
              padding: EdgeInsetsGeometry.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (svg != null) SvgPicture.asset(svg, width: svgSize,),
                          if (svg != null) const SizedBox(width: 12),
                          Text(
                            title,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      if (cancelText != null)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.all(20),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(128),
                                side: BorderSide(
                                  color: Get.theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onPressed: () => Get.back(result: false),
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveHelper.isTablet(Get.context!)
                                    ? 18
                                    : 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      if (cancelText != null && confirmText != null)
                        const SizedBox(width: 16),

                      if (confirmText != null)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              elevation: 0,
                              backgroundColor: Get.theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(128),
                              ),
                            ),
                            onPressed: () => Get.back(result: true),
                            child: Text(
                              confirmText,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveHelper.isTablet(Get.context!)
                                    ? 18
                                    : 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<String?> showForceUpdateDialog({
    required String title,
    required String message,
    String? svg,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) async {
    return Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: Get.width * 0.30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: Get.height * 0.80,
            ),
            child: CustomContainer(
              shape: Shape.square,
              borderColor: Get.theme.colorScheme.primary,
              padding: EdgeInsetsGeometry.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (svg != null) SvgPicture.asset(svg),
                          if (svg != null) const SizedBox(width: 12),
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      if (cancelText != null)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(128),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            onPressed: () => Get.back(result: false),
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveHelper.isTablet(Get.context!)
                                    ? 18
                                    : 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      if (cancelText != null && confirmText != null)
                        const SizedBox(width: 16),

                      if (confirmText != null)
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Get.theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(128),
                                ),
                              ),
                              onPressed: () async {
                                    await launchUrl(
                                      Uri.parse(UrlConstants.updateApp),
                                    );
                              },
                              child: Text(
                                confirmText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  ResponsiveHelper.isTablet(Get.context!)
                                      ? 18
                                      : 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}