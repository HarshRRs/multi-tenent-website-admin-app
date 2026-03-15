import 'package:flutter/material.dart';
import 'package:event_bite/core/theme/app_colors.dart';
import 'package:event_bite/core/theme/app_text_styles.dart';
import 'package:event_bite/features/reservations/domain/reservation_models.dart';

class FloorMapWidget extends StatelessWidget {
  final List<RestaurantTable> tables;
  final Function(RestaurantTable) onTableTap;

  const FloorMapWidget({
    super.key,
    required this.tables,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: tables.map((table) {
              // Convert relative coordinates (0.0-1.0) to pixels
              final left = table.x * constraints.maxWidth;
              final top = table.y * constraints.maxHeight;
              final tableSize = 60.0 + (table.seats * 5); // Simple sizing logic

              return Positioned(
                left: left,
                top: top,
                child: GestureDetector(
                  onTap: () => onTableTap(table),
                  child: Column(
                    children: [
                      Container(
                        width: tableSize,
                        height: tableSize,
                        decoration: BoxDecoration(
                          color: _getStatusColor(table.status),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            table.name,
                            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, size: 12, color: AppColors.textSecondaryLight),
                            const SizedBox(width: 2),
                            Text('\${table.seats}', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return AppColors.success;
      case TableStatus.reserved:

      case TableStatus.occupied:
        return AppColors.error;
    }
  }
}
