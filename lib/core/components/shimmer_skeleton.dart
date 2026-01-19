import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          const ShimmerSkeleton(
            width: double.infinity,
            height: 140,
            borderRadius: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                const ShimmerSkeleton(width: 120, height: 16),
                const SizedBox(height: 8),
                // Description placeholder (2 lines)
                const ShimmerSkeleton(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                const ShimmerSkeleton(width: 150, height: 12),
                const SizedBox(height: 12),
                // Price and button placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerSkeleton(width: 60, height: 20),
                    ShimmerSkeleton(width: 32, height: 32, borderRadius: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
