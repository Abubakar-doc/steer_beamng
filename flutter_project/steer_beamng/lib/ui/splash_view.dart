import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            Text(
              'Steer Beamng',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
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
