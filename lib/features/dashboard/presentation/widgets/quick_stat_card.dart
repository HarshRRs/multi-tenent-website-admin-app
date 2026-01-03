import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';

class QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color baseColor;
  final int delay;

  const QuickStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.baseColor = AppColors.primaryLight,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: baseColor, size: 20),
              ),
              Icon(Icons.more_horiz, color: AppColors.textSecondaryLight.withValues(alpha: 0.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: delay.ms).fadeIn().moveY(begin: 10, end: 0, duration: 400.ms);
  }
}
