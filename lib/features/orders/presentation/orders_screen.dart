import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:rockster/features/orders/presentation/orders_provider.dart';
import 'package:rockster/features/orders/presentation/widgets/kanban_column.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}



class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Enable Wake Lock for Kitchen Display
    WakelockPlus.enable();
    
    // Refresh orders when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  void _onOrderDropped(Order order, OrderStatus newStatus) {
    if (order.status == newStatus) return;
    
    // Call provider to update status
    ref.read(ordersProvider.notifier).updateOrderStatus(order.id, newStatus).then((_) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #\${order.id} moved to \${_getStatusName(newStatus)}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: \$e'),
          backgroundColor: AppColors.error,
        ),
      );
    });
  }

  String _getStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final allOrders = ordersState.orders;
    final isLoading = ordersState.status == DataStatus.loading && allOrders.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Orders'),
        actions: [
          if (ordersState.status == DataStatus.loading)
             const Padding(
               padding: EdgeInsets.symmetric(horizontal: 16.0),
               child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
             ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ordersProvider.notifier).refresh(),
          ),
        ],
      ),
      body: _buildBody(ordersState, allOrders, isLoading),
    );
  }

  Widget _buildBody(OrdersState state, List<Order> allOrders, bool isLoading) {
    if (state.status == DataStatus.error) {
       return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load orders',
                style: AppTextStyles.headlineMedium,
              ),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(ordersProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              )
            ],
          ),
        );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allOrders.isEmpty && state.status == DataStatus.success) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No live orders', style: AppTextStyles.headlineMedium),
               const SizedBox(height: 8),
              Text('New orders will appear here automatically', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(ordersProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Check for Updates'),
              )
            ],
          ),
        );
    }

    return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KanbanColumn(
                      title: 'New',
                      status: OrderStatus.newOrder,
                      orders: allOrders.where((o) => o.status == OrderStatus.newOrder).toList(),
                      onOrderDropped: _onOrderDropped,
                      headerColor: AppColors.info,
                      icon: Icons.notifications_active,
                    ),
                    KanbanColumn(
                      title: 'Preparing',
                      status: OrderStatus.preparing,
                      orders: allOrders.where((o) => o.status == OrderStatus.preparing).toList(),
                      onOrderDropped: _onOrderDropped,
                      headerColor: AppColors.warning,
                      icon: Icons.kitchen,
                    ),
                    KanbanColumn(
                      title: 'Ready',
                      status: OrderStatus.ready,
                      orders: allOrders.where((o) => o.status == OrderStatus.ready).toList(),
                      onOrderDropped: _onOrderDropped,
                      headerColor: AppColors.success,
                      icon: Icons.check_circle,
                    ),
                    KanbanColumn(
                      title: 'Out for Delivery',
                      status: OrderStatus.outForDelivery,
                      orders: allOrders.where((o) => o.status == OrderStatus.outForDelivery).toList(),
                      onOrderDropped: _onOrderDropped,
                      headerColor: AppColors.tertiaryLight,
                      icon: Icons.delivery_dining,
                    ),
                  ],
                ),
              ),
            );

  }
}
