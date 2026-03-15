import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/glass_bottom_nav.dart';
import 'package:rockster/core/components/brand_gradient_line.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/core/providers/providers.dart';


class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  List<NavItem> _getNavItems(String? businessType) {
    final isRetail = businessType == 'retail';
    
    return [
      const NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
      ),
      const NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders',
      ),
      NavItem(
        icon: isRetail ? Icons.inventory_2_outlined : Icons.restaurant_menu_outlined,
        activeIcon: isRetail ? Icons.inventory_2 : Icons.restaurant_menu,
        label: isRetail ? 'Products' : 'Menu',
      ),
      if (!isRetail)
        const NavItem(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today,
          label: 'Bookings',
        ),
      const NavItem(
        icon: Icons.more_horiz_outlined,
        activeIcon: Icons.more_horiz,
        label: 'More',
      ),
    ];
  }

  List<String> _getRoutes(String? businessType) {
    final isRetail = businessType == 'retail';
    
    if (isRetail) {
      return ['/', '/orders', '/menu', '/settings'];
    } else {
      return ['/', '/orders', '/menu', '/reservations', '/more'];
    }
  }

  int _getCurrentIndex(String location, List<String> routes) {
    for (int i = 0; i < routes.length; i++) {
      if (location == routes[i]) return i;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // Check initial state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.authenticated) {
        ref.read(webSocketServiceProvider).connect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        ref.read(webSocketServiceProvider).connect();
      } else if (next.status == AuthStatus.unauthenticated) {
        ref.read(webSocketServiceProvider).disconnect();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final businessType = authState.user?.businessType;
    
    final navItems = _getNavItems(businessType);
    final routes = _getRoutes(businessType);
    final currentIndex = _getCurrentIndex(GoRouterState.of(context).uri.path, routes);

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: Column(
        children: [
          const BrandGradientLine(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: currentIndex,
        items: navItems,
        onTap: (index) {
          if (index < routes.length) {
            context.go(routes[index]);
          }
        },
      ),
    );
  }
}
