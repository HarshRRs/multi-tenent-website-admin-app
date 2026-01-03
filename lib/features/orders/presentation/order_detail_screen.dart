import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/orders/domain/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // In a real app, we would fetch the order by ID here.
    // For now, we reuse the dummy data logic or just create a mock object.
    final mockOrder = Order(
      id: orderId,
      customerName: 'Alice Johnson',
      items: [
        OrderItem(name: 'Cheese Burger', quantity: 2),
        OrderItem(name: 'Fries', quantity: 1),
        OrderItem(name: 'Coke Zero', quantity: 1),
      ],
      totalAmount: 28.50,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: OrderStatus.newOrder,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #\$orderId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryLight),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: AppTextStyles.labelMedium),
                      Text('Preparing', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info
            _buildSectionCard(
              title: 'Customer Details',
              child: Column(
                children: [
                  _buildCustomerRow(Icons.person, mockOrder.customerName),
                  const SizedBox(height: 12),
                  _buildCustomerRow(Icons.phone, '+1 (555) 123-4567'),
                  const SizedBox(height: 12),
                  _buildCustomerRow(Icons.location_on, '123 Main St, Apt 4B\nNew York, NY'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Items
            _buildSectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  ...mockOrder.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('\${item.quantity}x', style: AppTextStyles.labelLarge),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.name, style: AppTextStyles.bodyMedium)),
                            Text('€12.00', style: AppTextStyles.bodyMedium), // Mock price
                          ],
                        ),
                      )),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.headlineMedium),
                      Text('€\${mockOrder.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ],
              ),
            ),
             const SizedBox(height: 16),

            // Timeline (Simplified)
            _buildSectionCard(
              title: 'Timeline',
              child: Column(
                children: [
                  _buildTimelineItem('Order Placed', '10:30 AM', true, true),
                  _buildTimelineItem('Accepted', '10:32 AM', true, true),
                  _buildTimelineItem('Preparing', '10:35 AM', true, false),
                  _buildTimelineItem('Ready', '--:--', false, false),
                  _buildTimelineItem('Delivered', '--:--', false, false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            CustomButton(
              text: 'Mark as Ready',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Cancel Order',
              isOutlined: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomerRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, bool isCompleted, bool isConnect) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryLight : AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? AppColors.primaryLight : Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            if (isConnect)
              Container(
                width: 2,
                height: 30,
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            if (title != 'Ready' && title != 'Delivered')
            Text(time, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ],
    );
  }
}
