import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_bite/core/components/main_layout.dart';
import 'package:event_bite/features/dashboard/presentation/dashboard_screen.dart';
import 'package:event_bite/features/orders/presentation/orders_screen.dart';
import 'package:event_bite/features/menu/presentation/menu_screen.dart';
import 'package:event_bite/features/menu/presentation/add_edit_product_screen.dart';
import 'package:event_bite/features/reservations/presentation/reservations_screen.dart';
import 'package:event_bite/features/payments/presentation/payments_screen.dart';
import 'package:event_bite/features/website_customizer/presentation/website_customizer_screen.dart';
import 'package:event_bite/features/notifications/presentation/notifications_screen.dart';
import 'package:event_bite/features/settings/presentation/settings_screen.dart';
import 'package:event_bite/features/more/presentation/more_screen.dart';
import 'package:event_bite/features/auth/presentation/login_screen.dart';
import 'package:event_bite/features/auth/presentation/register_screen.dart';
import 'package:event_bite/features/orders/presentation/order_detail_screen.dart';
import 'package:event_bite/features/auth/presentation/forgot_password_screen.dart';
import 'package:event_bite/features/auth/presentation/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Changed from /login to let redirect handle it
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      if (!isAuth) {
         if (isLoggingIn || isRegistering) return null;
         return '/login';
      }

      if (isLoggingIn || isRegistering) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/order/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OrderDetailScreen(orderId: id);
            },
          ),
          GoRoute(
            path: '/menu',
            builder: (context, state) => const MenuScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return AddEditProductScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) => const ReservationsScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: '/website-customizer',
            builder: (context, state) => const WebsiteCustomizerScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
    ],
  );
});
