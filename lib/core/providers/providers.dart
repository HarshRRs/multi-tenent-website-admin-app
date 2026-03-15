import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_bite/core/network/api_client.dart';
import 'package:event_bite/core/utils/cache_service.dart';
import 'package:event_bite/core/utils/secure_storage.dart';
import 'package:event_bite/features/auth/data/auth_repository_impl.dart';
import 'package:event_bite/features/auth/data/auth_service.dart';
import 'package:event_bite/features/auth/domain/auth_repository.dart';
import 'package:event_bite/features/dashboard/data/dashboard_service.dart';
import 'package:event_bite/features/menu/data/menu_service.dart';
import 'package:event_bite/features/orders/data/order_service.dart';
import 'package:event_bite/features/payments/data/payment_service.dart';
import 'package:event_bite/features/reservations/data/reservation_service.dart';
import 'package:event_bite/features/website_customizer/data/website_service.dart';
import 'package:event_bite/core/network/websocket_service.dart';

import 'package:event_bite/core/providers/messenger_provider.dart';

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
final webSocketServiceProvider = Provider<WebSocketService>((ref) => WebSocketService());
