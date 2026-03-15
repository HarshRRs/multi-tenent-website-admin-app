import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_bite/core/theme/app_colors.dart';
// import 'package:event_bite/core/theme/app_text_styles.dart';
import 'package:event_bite/features/notifications/domain/notification_model.dart';
import 'package:event_bite/features/notifications/presentation/notifications_provider.dart';
import 'package:intl/intl.dart';
import 'package:event_bite/core/components/modern_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_bite/features/notifications/presentation/widgets/notification_settings_sheet.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.deepInk),
        ),
        backgroundColor: AppColors.cloudDancer,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepInk),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.deepInk),
            onPressed: () {
               showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const NotificationSettingsSheet(),
              );
            },
          ),
          if (notificationsState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(color: AppColors.burntTerracotta, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: notificationsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta))
          : notificationsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${notificationsState.error}',
                        style: GoogleFonts.inter(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(notificationsProvider.notifier).loadNotifications();
                        },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.burntTerracotta,
                           foregroundColor: Colors.white,
                         ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : notificationsState.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 48, color: AppColors.textSecondaryLight.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.burntTerracotta,
                      onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notificationsState.notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = notificationsState.notifications[index];
                          return ModernCard(
                            padding: EdgeInsets.zero,
                            onTap: () {
                                if (!notification.isRead) {
                                  ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                                }
                            },
                            child: Container(
                              color: notification.isRead
                                  ? Colors.transparent
                                  : AppColors.burntTerracotta.withValues(alpha: 0.05),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: GoogleFonts.inter(
                                                  fontWeight: notification.isRead
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                  color: AppColors.deepInk,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatTime(notification.timestamp),
                                              style: GoogleFonts.inter(
                                                color: AppColors.textSecondaryLight,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: GoogleFonts.inter(
                                            color: AppColors.textSecondaryLight,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return AppColors.success;
      case NotificationType.system:
        return AppColors.wildRose; // Updated from primaryLight
      case NotificationType.promotion:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.promotion:
        return Icons.star_border;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
