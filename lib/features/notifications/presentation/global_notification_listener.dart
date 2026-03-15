import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_bite/core/network/websocket_service.dart';
import 'package:event_bite/core/services/sound_service.dart';
import 'package:event_bite/features/notifications/presentation/notifications_provider.dart';
import 'package:event_bite/features/orders/presentation/orders_provider.dart';
import 'package:event_bite/core/providers/providers.dart'; // For API client if needed directly or other providers

class GlobalNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalNotificationListener({super.key, required this.child});

  @override
  ConsumerState<GlobalNotificationListener> createState() => _GlobalNotificationListenerState();
}

class _GlobalNotificationListenerState extends ConsumerState<GlobalNotificationListener> {
  final SoundService _soundService = SoundService();
  bool _isListening = false;
  WebSocketService? _wsService;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection or ensuring it's connected happens in main typically, 
    // but here we listen to the stream.
  }
  
  void _setupListener() {
    if (_isListening) return;
    
    // In a real app we might get the singleton WS service from a provider
    // Im assuming we have one instance or need to get it from somewhere.
    // Based on codebase search, WebSocketService is a class, but not clearly a singleton provider yet?
    // Looking at `websocket_service.dart`, it's a class. 
    // We should probably have a provider for it.
    
    // For now, I'll assume we can use a provider for it, or creating one.
    // However, the existing code didn't show a provider for WebSocketService.
    // I will Create a provider for it in this file or use one if it exists.
  }

  @override
  Widget build(BuildContext context) {
    // Watch a websocket provider if it exists
    final wsService = ref.watch(webSocketServiceProvider);
    
    // Listen to the stream
    ref.listen(webSocketStreamProvider, (previous, next) {
      next.whenData((data) {
        if (data is Map<String, dynamic>) {
           _handleEvent(data);
        }
      });
    });

    return widget.child;
  }

  void _handleEvent(Map<String, dynamic> data) {
    final type = data['type'];
    
    if (type == 'new_order' || type == 'order_update') {
      // Play sound
      _soundService.playOrderSound();
      
      // Refresh providers
      ref.read(ordersProvider.notifier).refresh();
      ref.read(notificationsProvider.notifier).loadNotifications();
    }
  }
}

// Define Providers if they don't exist globally yet
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  service.connect(); // Auto connect
  ref.onDispose(() => service.dispose());
  return service;
});

final webSocketStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.eventStream;
});
