import 'package:flutter/material.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';

class ProductCard extends StatelessWidget {
  final MenuItem product;
  final VoidCallback onEdit;
  final Function(bool) onAvailabilityChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Enhanced shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: product.isAvailable
                          ? null
                          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    ),
                    color: Colors.grey[200], // Placeholder color
                  ),
                ),
                if (!product.isAvailable)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.9), // Red badge
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        'Out of Stock',
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryLight),
                      tooltip: 'Edit item',
                      onPressed: onEdit,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '€\${product.price}',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.isAvailable ? 'Available' : 'Unavailable',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: product.isAvailable ? AppColors.success : AppColors.textSecondaryLight,
                      ),
                    ),
                    Switch.adaptive(
                      value: product.isAvailable,
                      onChanged: onAvailabilityChanged,
                      activeColor: AppColors.primaryLight,
                    ),
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
