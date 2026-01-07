import 'package:dio/dio.dart';
import 'package:rockster/features/notifications/domain/notification_model.dart';

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get('/notifications');
    final List notifications = response.data as List;
    return notifications.map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/notifications/mark-all-read');
  }
}
