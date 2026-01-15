import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Glowing text widget with pulsing cyan glow effect
class GlowingText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowRadius;

  const GlowingText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = Colors.cyan,
    this.glowRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? const TextStyle(fontSize: 48, fontWeight: FontWeight.w900);

    return Stack(
      children: [
        // Glow layer 1
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = glowColor.withOpacity(0.3)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
          ),
        ),
        // Glow layer 2
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = glowColor.withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          ),
        ),
        // Main text
        Text(
          text,
          style: textStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    )
      .animate(onPlay: (controller) => controller.repeat())
      .shimmer(
        duration: 2000.ms,
        color: glowColor.withOpacity(0.3),
      )
      .then()
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.02, 1.02),
        duration: 1500.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .scale(
        begin: const Offset(1.02, 1.02),
        end: const Offset(1.0, 1.0),
        duration: 1500.ms,
        curve: Curves.easeInOut,
      );
  }
}
