import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/core/utils/cache_service.dart';
import 'package:rockster/features/orders/data/order_dto.dart';
import 'package:rockster/features/orders/data/order_service.dart';
import 'package:rockster/features/orders/domain/order_model.dart';
import 'package:rockster/features/dashboard/presentation/dashboard_provider.dart';

class OrdersState {
  final DataStatus status;
  final List<Order> orders;
  final String? error;

  OrdersState({
    required this.status,
    this.orders = const [],
    this.error,
  });

  OrdersState copyWith({
    DataStatus? status,
    List<Order>? orders,
    String? error,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }

  List<Order> ordersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrderService _orderService;
  final CacheService _cacheService;

  OrdersNotifier(this._orderService, this._cacheService)
      : super(OrdersState(status: DataStatus.initial)) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // Try cache first
    final cachedOrders = await _cacheService.getCachedList<Order>(
      'active_orders',
      (json) => orderFromJson(json),
    );

    if (cachedOrders != null) {
      state = state.copyWith(
        status: DataStatus.success,
        orders: cachedOrders,
      );
    }

    // Fetch fresh data
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(status: DataStatus.loading);

    try {
      final orders = await _orderService.getOrders();

      // Cache orders
      await _cacheService.cache(
        'active_orders',
        orders.map((o) => orderToJson(o)).toList(),
      );

      state = state.copyWith(
        status: DataStatus.success,
        orders: orders,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Optimistic update
    final updatedOrders = state.orders.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedOrders);

    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      
      // Invalidate cache
      await _cacheService.invalidate('active_orders');
      await _cacheService.invalidate('dashboard_stats');
    } catch (e) {
      // Revert on error
      await refresh();
      rethrow;
    }
  }

  void updateOrderFromWebSocket(Order updatedOrder) {
    final orderIndex = state.orders.indexWhere((o) => o.id == updatedOrder.id);
    
    if (orderIndex >= 0) {
      final updatedOrders = List<Order>.from(state.orders);
      updatedOrders[orderIndex] = updatedOrder;
      state = state.copyWith(orders: updatedOrders);
    } else {
      // New order
      state = state.copyWith(orders: [...state.orders, updatedOrder]);
    }
  }

  void removeOrder(String orderId) {
    final updatedOrders = state.orders.where((o) => o.id != orderId).toList();
    state = state.copyWith(orders: updatedOrders);
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return OrdersNotifier(orderService, cacheService);
});
