import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/notifications/data/notification_service.dart';
import 'package:rockster/features/notifications/domain/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient.dio);
});

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsNotifier(service);
});

class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationService _service;

  NotificationsNotifier(this._service) : super(NotificationsState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _service.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      // Update local state optimistically
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            title: n.title,
            body: n.body,
            timestamp: n.timestamp,
            isRead: true,
            type: n.type,
          );
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      // Update all to read
      final updatedNotifications = state.notifications.map((n) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timestamp: n.timestamp,
          isRead: true,
          type: n.type,
        );
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
