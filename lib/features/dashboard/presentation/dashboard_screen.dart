import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/core/components/elite_button.dart';
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

    _scheduleMidnightRefresh();
  }

  void _scheduleMidnightRefresh() {
    _timer?.cancel();
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _timer = Timer(timeUntilMidnight, () {
      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now();
        });
        _onRefresh();
        _scheduleMidnightRefresh();
      }
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
              primary: AppColors.liquidAmber,
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
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.liquidAmber,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ELITE INTELLIGENCE',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.liquidAmber,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'System Overview',
                          style: AppTextStyles.displayLarge,
                        ),
                        _buildDateTrigger(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.liquidAmber)),
              )
            else if (dashboardState.status == DataStatus.error)
              _buildErrorState()
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeroMetric(stats),
                    
                    const SizedBox(height: 32),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        StatCard(
                          title: 'Active Orders',
                          value: stats?.activeOrders.toString() ?? '0',
                          icon: Icons.receipt_long_outlined,
                          trend: '+12%',
                        ),
                        StatCard(
                          title: 'Reservations',
                          value: stats?.reservations.toString() ?? '0',
                          icon: Icons.calendar_today_outlined,
                          trend: '+5%',
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    
                    _buildRecentOrdersHeader(),
                    const SizedBox(height: 16),
                    if (recentOrders.isEmpty)
                      _buildEmptyOrdersState()
                    else
                      ...recentOrders.map((order) => _buildEliteOrderCard(order)),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTrigger() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.calendar_month_outlined, color: AppColors.deepInk),
      ),
    );
  }

  Widget _buildHeroMetric(DashboardStats? stats) {
    return ModernCard(
      padding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL REVENUE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                stats != null ? '€${stats.totalRevenue.toStringAsFixed(2)}' : '€0.00',
                style: AppTextStyles.displayLarge.copyWith(fontSize: 40),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${stats?.revenueTrend ?? '0%'} increase this week',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _PulseIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Live Activity',
          style: AppTextStyles.headlineLarge,
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See All',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.liquidAmber),
          ),
        ),
      ],
    );
  }

  Widget _buildEliteOrderCard(RecentOrder order) {
    final statusColor = _getStatusColor(order.status);
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  style: AppTextStyles.labelLarge,
                ),
                Text(
                  order.customerName,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${order.amount.toStringAsFixed(2)}',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                order.status.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
        return AppColors.liquidAmber;
      case 'new':
      case 'pending':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Sync Interrupted', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            EliteButton(
              text: 'Re-sync Data',
              onPressed: _onRefresh,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No activity today', style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(1.0 - _controller.value),
                blurRadius: _controller.value * 10,
                spreadRadius: _controller.value * 5,
              ),
            ],
          ),
        );
      },
    );
  }
}
