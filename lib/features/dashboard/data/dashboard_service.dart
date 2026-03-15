import 'package:dio/dio.dart';
import 'package:event_bite/features/dashboard/data/dashboard_models.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<DashboardStats> getDashboardStats({DateTime? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) {
      queryParams['date'] = date.toIso8601String();
    }
    final response = await _dio.get('/dashboard/stats', queryParameters: queryParams);
    return DashboardStats.fromJson(response.data);
  }

  Future<List<RecentOrder>> getRecentOrders({int limit = 10}) async {
    final response = await _dio.get(
      '/dashboard/recent-orders',
      queryParameters: {'limit': limit},
    );
    
    return (response.data['orders'] as List?)
            ?.map((o) => RecentOrder.fromJson(o))
            .toList() ??
        [];
  }
}
