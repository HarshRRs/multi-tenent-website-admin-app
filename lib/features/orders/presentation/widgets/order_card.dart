import 'package:flutter/material.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    
    Widget cardContent = ModernCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(order.createdAt),
                style: AppTextStyles.labelMedium.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            order.customerName,
            style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.liquidAmber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${order.items.length - 2} more items',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelMedium.copyWith(color: Colors.grey),
              ),
              Text(
                '€${order.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.deepInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Draggable<Order>(
        data: order,
        feedback: SizedBox(
          width: 280,
          child: Material(
            color: Colors.transparent,
            child: cardContent,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: SizedBox(width: 280, child: cardContent),
        ),
        child: SizedBox(width: 280, child: cardContent),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.liquidAmber;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.outForDelivery:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }
}
