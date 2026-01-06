import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/features/dashboard/presentation/dashboard_provider.dart';
import 'package:rockster/features/dashboard/presentation/widgets/hero_stat_card.dart';
import 'package:rockster/features/dashboard/presentation/widgets/quick_stat_card.dart';
import 'package:rockster/features/dashboard/data/dashboard_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).refresh();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(dashboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final stats = dashboardState.stats;
    final recentOrders = dashboardState.recentOrders;
    final isLoading = dashboardState.status == DataStatus.loading && stats == null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll for RefreshIndicator
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 80,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    'Hello, ${ref.watch(authNotifierProvider).user?.name ?? "User"}',
                    style: AppTextStyles.headlineMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
              ),
              actions: [
                if (dashboardState.status == DataStatus.loading)
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 16.0),
                     child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                   ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile settings coming soon')),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: AppColors.secondaryLight,
                      child: Icon(Icons.person, color: AppColors.primaryLight),
                    ),
                  ),
                ),
              ],
            ),

            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboardState.status == DataStatus.error)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Failed to load dashboard', style: AppTextStyles.headlineMedium),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(dashboardState.error ?? 'Unknown error', textAlign: TextAlign.center),
                      ),
                      FilledButton(
                        onPressed: _onRefresh,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Card
                    HeroStatCard(
                      title: 'Total Revenue',
                      value: stats != null ? '€\${stats.totalRevenue.toStringAsFixed(2)}' : '€0.00',
                      trend: stats?.revenueTrend ?? '0%',
                      isPositive: stats?.isRevenueTrendPositive ?? true,
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.4,
                          children: [
                            QuickStatCard(
                              title: 'Active Orders',
                              value: (stats?.activeOrders ?? 0).toString(),
                              icon: Icons.receipt_long,
                              baseColor: AppColors.info,
                              delay: 100,
                            ),
                            QuickStatCard(
                              title: 'Reservations',
                              value: (stats?.reservations ?? 0).toString(),
                              icon: Icons.calendar_today,
                              baseColor: Colors.purple,
                              delay: 200,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Recent Orders Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Orders',
                          style: AppTextStyles.headlineMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        TextButton(
                          onPressed: () {}, // Navigate to Orders tab logic if needed
                          child: Text('View All', style: AppTextStyles.labelLarge),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent Orders List
                    if (recentOrders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No recent orders", style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...recentOrders.map((order) {
                        final color = _getStatusColor(order.status);
                        return _buildOrderListItem(
                          'Order #\${order.id}', 
                          order.customerName, 
                          '€\${order.amount.toStringAsFixed(2)}', 
                          order.status, 
                          color
                        );
                      }),
                    
                    const SizedBox(height: 80), // Bottom padding for FAB/Tab bar
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'completed':
        return Colors.green;
      case 'preparing':
        return AppColors.warning;
      case 'new':
      case 'pending':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderListItem(String orderId, String name, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight.withValues(alpha: 0.1), // Adjusted for safety
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderId, style: AppTextStyles.labelLarge),
                Text(name, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.labelLarge),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelMedium.copyWith(color: color),
                  textAlign: TextAlign.right, // Added alignment
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
