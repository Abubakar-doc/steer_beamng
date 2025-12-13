import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/ui/widgets/circular_loading_indicator.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 40
                ),
                children: [
                  TextSpan(text: 'Steer '),
                  TextSpan(
                    text: 'BeamNG',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 1000.ms, delay: 500.ms),
            const SizedBox(height: 30),
            CircularLoadingIndicator(
              size: 50,
              strokeWidth: 10,
            ).animate().fadeIn(duration: 1200.ms, delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
