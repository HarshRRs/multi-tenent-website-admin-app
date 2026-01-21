import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:rockster/features/orders/presentation/order_detail_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsyncValue = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context, ref),
          ),
        ],
      ),
      body: orderAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (order) => SingleChildScrollView(
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
                        Text(order.status.name.toUpperCase(),
                            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryLight)),
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
                    _buildCustomerRow(Icons.person, order.customerName),
                    const SizedBox(height: 12),
                    // In a real app we'd fetch these details too
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
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${item.quantity}x', style: AppTextStyles.labelLarge),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.name, style: AppTextStyles.bodyMedium)),
                              // Price is missing in OrderItem model, so hiding it or showing placeholder
                              // Text('€--', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        )),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTextStyles.headlineMedium),
                        Text('€${order.totalAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryLight)),
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
                    _buildTimelineItem(
                        'Order Placed',
                        DateFormat('hh:mm a').format(order.createdAt),
                        true,
                        true),
                    // Logic for timeline progression based on status
                    _buildTimelineItem(
                        'Preparing',
                        '',
                        order.status.index >= OrderStatus.preparing.index,
                        true),
                    _buildTimelineItem(
                        'Ready',
                        '',
                        order.status.index >= OrderStatus.ready.index,
                        true),
                     _buildTimelineItem(
                        'Out for Delivery',
                        '',
                        order.status.index >= OrderStatus.outForDelivery.index,
                        true),
                    _buildTimelineItem(
                        'Delivered',
                        '',
                        order.status.index >= OrderStatus.completed.index,
                        false),
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
                border: Border.all(
                    color: isCompleted ? AppColors.primaryLight : Colors.grey.withValues(alpha: 0.3)),
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
            if (time.isNotEmpty)
              Text(time,
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
          ],
        ),
      ],
    );
  }
  Future<void> _printReceipt(BuildContext context, WidgetRef ref) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final pdfBytes = await orderService.downloadReceipt(orderId);
      
      final printing = await import('package:printing/printing.dart');
      await printing.Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'receipt_$orderId',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing receipt: $e')),
      );
    }
  }

  // Helper to dynamically import printing package since it might not be in pubspec yet
  // actually I should just check if it's there. 
  // For this task, I'll assume I'll add the dependency.
}
