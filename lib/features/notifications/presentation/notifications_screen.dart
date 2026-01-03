import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/notifications/domain/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<AppNotification> notifications = [
      AppNotification(
        id: '1',
        title: 'New Order #1024',
        body: 'You have a new order from Alice Johnson for €25.50.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: NotificationType.order,
      ),
      AppNotification(
        id: '2',
        title: 'Payout Processed',
        body: 'Your weekly payout of €1,248.50 has been sent to your bank.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
        type: NotificationType.system,
      ),
      AppNotification(
        id: '3',
        title: 'Table Reserved',
        body: 'Table 5 has been reserved for 6 guests at 7:00 PM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
        type: NotificationType.order, // treating reservation as order type for icon
      ),
      AppNotification(
        id: '4',
        title: 'System Update',
        body: 'Rockster App has been updated to version 2.0. Check out the new Website Customizer!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.promotion,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            color: notification.isRead ? Colors.transparent : AppColors.primaryLight.withValues(alpha: 0.05),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 20,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatTime(notification.timestamp),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  notification.body,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () {
                // Navigate or mark as read logic
              },
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return AppColors.success;
      case NotificationType.system:
        return AppColors.primaryLight;
      case NotificationType.promotion:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.promotion:
        return Icons.star;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '\${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '\${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
