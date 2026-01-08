import 'package:flutter/material.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // We separate the shadow container from the material content to enable InkWell ripple
    // to be clipped by the rounded corners while keeping the shadow outside.
    Widget buildContent({bool isInteractive = true}) {
      return Container(
        width: 280, // Fixed width for columns
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: AppColors.surfaceLight,
            child: InkWell(
              onTap: isInteractive ? () => context.push('/order/${order.id}') : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: _getStatusColor(order.status),
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${order.id}',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondaryLight),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(order.createdAt),
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.customerName,
                      style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                ),
                                child: Text('${item.quantity}x', style: AppTextStyles.labelSmall),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item.name, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(
                          message: 'Delivery Order',
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delivery_dining, size: 16, color: AppColors.textSecondaryLight),
                          ),
                        ),
                        Text(
                          '€${order.totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final card = buildContent(isInteractive: true);

    return Draggable<Order>(
      data: order,
      feedback: Transform.scale(
        scale: 1.05,
        child: buildContent(isInteractive: false),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: card, // Non-interactive visual is fine, or keep it interactive but opaque
      ),
      child: card,
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.warning;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.outForDelivery:
        return AppColors.tertiaryLight;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
