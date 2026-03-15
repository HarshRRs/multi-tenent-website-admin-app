import 'package:flutter/material.dart';

/// Beautiful flower/nature background for Cosmos Admin
class CosmicBackground extends StatelessWidget {
  final Widget child;

  const CosmicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Beautiful flower background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/flower_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        
        // Semi-transparent overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}
