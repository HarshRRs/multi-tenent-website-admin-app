import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/main_layout.dart';
import 'package:rockster/features/dashboard/presentation/dashboard_screen.dart';
import 'package:rockster/features/orders/presentation/orders_screen.dart';
import 'package:rockster/features/menu/presentation/menu_screen.dart';
import 'package:rockster/features/menu/presentation/add_edit_product_screen.dart';
import 'package:rockster/features/reservations/presentation/reservations_screen.dart';
import 'package:rockster/features/tables/presentation/pages/table_management_screen.dart';
import 'package:rockster/features/payments/presentation/payments_screen.dart';
import 'package:rockster/features/website_customizer/presentation/website_customizer_screen.dart';
import 'package:rockster/features/website_customizer/presentation/subdomain_settings_screen.dart';
import 'package:rockster/features/notifications/presentation/notifications_screen.dart';
import 'package:rockster/features/settings/presentation/settings_screen.dart';
import 'package:rockster/features/marketing/presentation/coupons_screen.dart';
import 'package:rockster/features/marketing/presentation/reviews_screen.dart';
import 'package:rockster/features/more/presentation/more_screen.dart';
import 'package:rockster/features/auth/presentation/login_screen.dart';
import 'package:rockster/features/auth/presentation/register_screen.dart';
import 'package:rockster/features/orders/presentation/order_detail_screen.dart';
import 'package:rockster/features/auth/presentation/forgot_password_screen.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/features/red_flags/presentation/onboarding_screen.dart';

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
      final isForgotPassword = state.uri.toString() == '/forgot-password';
      final isOnboarding = state.uri.toString() == '/onboarding';

      if (!isAuth) {
         if (isLoggingIn || isRegistering || isForgotPassword || isOnboarding) return null;
         return '/onboarding';
      }

      if (isLoggingIn || isRegistering) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const OrdersScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/order/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomTransitionPage(
                key: state.pageKey,
                child: OrderDetailScreen(orderId: id),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MenuScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ReservationsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/tables',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TableManagementScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/payments',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PaymentsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/website-customizer',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WebsiteCustomizerScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/subdomain-settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SubdomainSettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/coupons',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CouponsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/reviews',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ReviewsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MoreScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
});
