import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:event_bite/core/theme/app_colors.dart';

/// 2px Brand Gradient Line (Orange â†’ Rose)
class BrandGradientLine extends StatelessWidget {
  const BrandGradientLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.burntTerracotta,
            AppColors.wildRose,
          ],
        ),
      ),
    );
  }
}
