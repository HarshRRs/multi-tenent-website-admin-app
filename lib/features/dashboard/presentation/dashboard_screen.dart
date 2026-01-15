import 'dart:async'; // Added
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/core/components/glossy_metric_card.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/features/dashboard/presentation/dashboard_provider.dart';
import 'package:rockster/features/dashboard/data/dashboard_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _timer;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).refresh();
    });

    // Auto-refresh every 24 hours
    _timer = Timer.periodic(const Duration(hours: 24), (timer) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(dashboardProvider.notifier).refresh(date: _selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.burntTerracotta,
              onPrimary: Colors.white,
              onSurface: AppColors.deepInk,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await ref.read(dashboardProvider.notifier).refresh(date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final stats = dashboardState.stats;
    final recentOrders = dashboardState.recentOrders;
    final isLoading = dashboardState.status == DataStatus.loading && stats == null;
    final userName = ref.watch(authNotifierProvider).user?.name ?? "User";

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: Stack(
        children: [
          // Floral Background (Faded)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/flower_background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(), // Fallback if image missing
              ),
            ),
          ),
          
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.burntTerracotta,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Modern Header with subtle gradient/flower overlay
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 110,
                  backgroundColor: AppColors.cloudDancer.withValues(alpha: 0.95),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.deepInk),
                        onPressed: () {
                          // Navigate to notifications or show snackbar
                          // For now, let's keep the snackbar or implement navigation if needed
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No new notifications')),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta)),
                  )
                else if (dashboardState.status == DataStatus.error)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: AppColors.error.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepInk,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              dashboardState.error ?? 'Unknown error',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _onRefresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.burntTerracotta,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Featured Metric (Revenue)
                        GlossyMetricCard(
                          title: 'Total Revenue',
                          value: stats != null ? '€${stats.totalRevenue.toStringAsFixed(0)}' : '€0',
                          icon: Icons.euro_outlined,
                          color: AppColors.burntTerracotta,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Recent Orders Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Orders',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepInk,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'View All',
                                style: GoogleFonts.inter(
                                  color: AppColors.burntTerracotta,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Recent Orders List
                        if (recentOrders.isEmpty)
                          ModernCard(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 40,
                                      color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No recent orders',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondaryLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...recentOrders.map((order) {
                            final color = _getStatusColor(order.status);
                            return _buildOrderCard(order, color);
                          }),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'completed':
        return AppColors.success;
      case 'preparing':
        return AppColors.burntTerracotta;
      case 'new':
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Widget _buildOrderCard(RecentOrder order, Color statusColor) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.burntTerracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.burntTerracotta,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepInk,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${order.amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepInk,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
