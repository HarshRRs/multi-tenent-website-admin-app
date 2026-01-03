import 'package:rockster/features/orders/domain/order_model.dart';

class OrdersResponse {
  final List<Order> orders;
  final int total;

  OrdersResponse({
    required this.orders,
    required this.total,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List?)
              ?.map((o) => orderFromJson(o))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

// Helper functions
Order orderFromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'] ?? '',
    customerName: json['customerName'] ?? '',
    items: (json['items'] as List?)
            ?.map((i) => orderItemFromJson(i))
            .toList() ??
        [],
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    status: _parseOrderStatus(json['status']),
  );
}

OrderStatus _parseOrderStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'new':
    case 'neworder':
      return OrderStatus.newOrder;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.ready;
    case 'outfordelivery':
    case 'out_for_delivery':
      return OrderStatus.outForDelivery;
    case 'completed':
      return OrderStatus.completed;
    default:
      return OrderStatus.newOrder;
  }
}

OrderItem orderItemFromJson(Map<String, dynamic> json) {
  return OrderItem(
    name: json['name'] ?? '',
    quantity: json['quantity'] ?? 1,
  );
}

Map<String, dynamic> orderToJson(Order order) {
  return {
    'id': order.id,
    'customerName': order.customerName,
    'items': order.items.map((i) => orderItemToJson(i)).toList(),
    'totalAmount': order.totalAmount,
    'createdAt': order.createdAt.toIso8601String(),
    'status': order.status.name,
  };
}

Map<String, dynamic> orderItemToJson(OrderItem item) {
  return {
    'name': item.name,
    'quantity': item.quantity,
  };
}
