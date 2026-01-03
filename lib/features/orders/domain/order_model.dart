enum OrderStatus {
  newOrder,
  preparing,
  ready,
  outForDelivery,
  completed,
}

class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});
}

class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final OrderStatus status;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      customerName: customerName,
      items: items,
      totalAmount: totalAmount,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
