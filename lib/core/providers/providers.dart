import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/network/api_client.dart';
import 'package:rockster/core/utils/cache_service.dart';
import 'package:rockster/core/utils/secure_storage.dart';
import 'package:rockster/features/auth/data/auth_repository_impl.dart';
import 'package:rockster/features/auth/data/auth_service.dart';
import 'package:rockster/features/auth/domain/auth_repository.dart';
import 'package:rockster/features/dashboard/data/dashboard_service.dart';
import 'package:rockster/features/menu/data/menu_service.dart';
import 'package:rockster/features/orders/data/order_service.dart';
import 'package:rockster/features/payments/data/payment_service.dart';
import 'package:rockster/features/reservations/data/reservation_service.dart';
import 'package:rockster/features/website_customizer/data/website_service.dart';
import 'package:rockster/core/network/websocket_service.dart';
import 'package:rockster/core/services/sound_service.dart';
import 'package:rockster/core/providers/sound_provider.dart';

import 'package:rockster/core/providers/messenger_provider.dart';

// Core Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  final messengerKey = ref.watch(messengerKeyProvider);
  return ApiClient.getInstance(messengerKey);
});

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

// Auth Providers
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(authService, secureStorage);
});

// Order Providers
final orderServiceProvider = Provider<OrderService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderService(apiClient.dio);
});

// Dashboard Providers
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardService(apiClient.dio);
});

// Menu Providers
final menuServiceProvider = Provider<MenuService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MenuService(apiClient.dio);
});

// Reservation Providers
final reservationServiceProvider = Provider<ReservationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReservationService(apiClient.dio);
});

// Payment Providers
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient.dio);
});

// Website Providers
final websiteServiceProvider = Provider<WebsiteService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WebsiteService(apiClient.dio);
});
// WebSocket Provider
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
