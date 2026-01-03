import 'package:dio/dio.dart';
import 'package:rockster/features/dashboard/data/dashboard_models.dart';

class DashboardService {
  final Dio _dio;

  DashboardService(this._dio);

  Future<DashboardStats> getDashboardStats() async {
    final response = await _dio.get('/dashboard/stats');
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
