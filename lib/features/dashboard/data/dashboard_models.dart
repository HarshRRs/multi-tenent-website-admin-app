class DashboardStats {
  final double totalRevenue;
  final String revenueTrend;
  final bool isRevenueTrendPositive;
  final int activeOrders;
  final int reservations;
  final int menuItemsActive;
  final double rating;

  DashboardStats({
    required this.totalRevenue,
    required this.revenueTrend,
    required this.isRevenueTrendPositive,
    required this.activeOrders,
    required this.reservations,
    required this.menuItemsActive,
    required this.rating,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueTrend: json['revenueTrend'] ?? '+0%',
      isRevenueTrendPositive: json['isRevenueTrendPositive'] ?? true,
      activeOrders: json['activeOrders'] ?? 0,
      reservations: json['reservations'] ?? 0,
      menuItemsActive: json['menuItemsActive'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentOrder {
  final String id;
  final String customerName;
  final double amount;
  final String status;

  RecentOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }
}
