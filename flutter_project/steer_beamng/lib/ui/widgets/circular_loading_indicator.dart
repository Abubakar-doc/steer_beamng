import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircularLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final List<Color>? colors;

  const CircularLoadingIndicator({
    super.key,
    this.size = 55.0,
    this.strokeWidth = 10.0,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final RxDouble rotation = 0.0.obs;

    // Animate the rotation continuously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const duration = Duration(milliseconds: 2200);
      const fps = 60;
      final frameTime = duration.inMilliseconds ~/ fps;
      double angle = 0;

      // continuous loop
      Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: frameTime));
        angle += 2 * math.pi / fps; // full rotation every 2.2 s
        rotation.value = angle % (2 * math.pi);
        return true; // keep looping
      });
    });

    return Obx(() {
      final gradientColors = colors ??
          [Get.theme.colorScheme.primary, Get.theme.colorScheme.primary];

      return SizedBox(
        width: size,
        height: size,
        child: Transform.rotate(
          angle: rotation.value,
          child: CustomPaint(
            painter: _GradientLoadingPainter(
              colors: gradientColors,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
      );
    });
  }
}

class _GradientLoadingPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;

  _GradientLoadingPainter({required this.colors, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [colors.first.withValues(alpha: 0.0), ...colors, colors.last],
      stops: const [0.0, 0.5, 0.9, 1.0],
      startAngle: 0,
      endAngle: math.pi * 2,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GradientLoadingPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.strokeWidth != strokeWidth;
}
