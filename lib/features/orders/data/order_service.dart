import 'package:dio/dio.dart';
import 'package:rockster/features/orders/data/order_dto.dart';
import 'package:rockster/features/orders/domain/order_model.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<List<Order>> getOrders({OrderStatus? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status.name;
    }

    final response = await _dio.get('/orders', queryParameters: queryParams);
    final ordersResponse = OrdersResponse.fromJson(response.data);
    return ordersResponse.orders;
  }

  Future<Order> getOrderById(String id) async {
    final response = await _dio.get('/orders/$id');
    return orderFromJson(response.data);
  }

  Future<Order> createOrder(Order order) async {
    final response = await _dio.post(
      '/orders',
      data: orderToJson(order),
    );
    return orderFromJson(response.data);
  }

  Future<Order> updateOrderStatus(String id, OrderStatus status) async {
    final response = await _dio.patch(
      '/orders/$id/status',
      data: {'status': status.name},
    );
    return orderFromJson(response.data);
  }

  Future<void> deleteOrder(String id) async {
    await _dio.delete('/orders/$id');
  }
}
