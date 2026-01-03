import 'package:flutter/material.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:rockster/features/orders/presentation/widgets/order_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final OrderStatus status;
  final List<Order> orders;
  final Function(Order, OrderStatus) onOrderDropped;
  final Color headerColor;
  final IconData icon;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.orders,
    required this.onOrderDropped,
    required this.headerColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Order>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onOrderDropped(details.data, status),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 320,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? headerColor.withValues(alpha: 0.05)
                : AppColors.backgroundLight, // Highlight if drag hover
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: candidateData.isNotEmpty ? headerColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: headerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: headerColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orders.length.toString(),
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return OrderCard(order: orders[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
