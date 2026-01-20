import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/network/websocket_service.dart';
import 'package:rockster/core/services/sound_service.dart';
import 'package:rockster/features/notifications/presentation/notifications_provider.dart';
import 'package:rockster/features/orders/presentation/orders_provider.dart';
import 'package:rockster/features/reservations/presentation/reservations_provider.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/core/providers/sound_provider.dart';

class GlobalNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalNotificationListener({super.key, required this.child});

  @override
  ConsumerState<GlobalNotificationListener> createState() => _GlobalNotificationListenerState();
}

class _GlobalNotificationListenerState extends ConsumerState<GlobalNotificationListener> {
  bool _isListening = false;
  WebSocketService? _wsService;

  @override
  void initState() {
    super.initState();
  }
  
  void _setupListener() {
    if (_isListening) return;
  }

  @override
  Widget build(BuildContext context) {
    // Watch a websocket provider if it exists
    final wsService = ref.watch(webSocketServiceProvider);
    final soundService = ref.watch(soundServiceProvider);
    
    // Listen to the stream
    ref.listen(webSocketStreamProvider, (previous, next) {
      next.whenData((data) {
        if (data is Map<String, dynamic>) {
           _handleEvent(data, soundService);
        }
      });
    });

    return widget.child;
  }

  void _handleEvent(Map<String, dynamic> data, SoundService soundService) {
    final type = data['type'];
    
    if (type == 'new_order') {
      // Play loop sound
      soundService.playOrderSound(loop: true);
      
      // Refresh providers
      ref.read(ordersProvider.notifier).refresh();
      ref.read(notificationsProvider.notifier).loadNotifications();
    } else if (type == 'order_update') {
      // Stop sound on any order update (likely accepted/declined elsewhere)
      soundService.stopOrderSound();
      
      // Refresh providers
      ref.read(ordersProvider.notifier).refresh();
      ref.read(notificationsProvider.notifier).loadNotifications();
    } else if (type == 'new_reservation') {
      // Play sound
      soundService.playOrderSound(loop: true); // Or distinct sound if available
      
      // Refresh providers
      ref.read(reservationsProvider.notifier).loadReservations();
      ref.read(notificationsProvider.notifier).loadNotifications();
    }
  }
}

// Duplicate providers removed
