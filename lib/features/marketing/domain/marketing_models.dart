class Coupon {
  final String id;
  final String code;
  final String discountType; // "PERCENT" or "FIXED"
  final double discountValue;
  final double minOrderAmount;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.expiresAt,
    required this.isActive,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountType: json['discountType'],
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Review {
  final String id;
  final int rating;
  final String? comment;
  final String customerName;
  final String productId;
  final String? productName; // From include
  final bool isApproved;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.customerName,
    required this.productId,
    this.productName,
    required this.isApproved,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      customerName: json['customerName'],
      productId: json['productId'],
      productName: json['product']?['name'],
      isApproved: json['isApproved'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
