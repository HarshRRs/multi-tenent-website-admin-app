import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_bite/core/providers/providers.dart';
import 'package:event_bite/features/orders/domain/order_model.dart';

final orderDetailProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderById(orderId);
});
