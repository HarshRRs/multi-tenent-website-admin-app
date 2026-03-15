import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/core/utils/cache_service.dart';
import 'package:rockster/features/dashboard/data/dashboard_models.dart';
import 'package:rockster/features/dashboard/data/dashboard_service.dart';

enum DataStatus { initial, loading, success, error }

class DashboardState {
  final DataStatus status;
  final DashboardStats? stats;
  final List<RecentOrder> recentOrders;
  final String? error;

  DashboardState({
    required this.status,
    this.stats,
    this.recentOrders = const [],
    this.error,
  });

  DashboardState copyWith({
    DataStatus? status,
    DashboardStats? stats,
    List<RecentOrder>? recentOrders,
    String? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentOrders: recentOrders ?? this.recentOrders,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _dashboardService;
  final CacheService _cacheService;

  DashboardNotifier(this._dashboardService, this._cacheService)
      : super(DashboardState(status: DataStatus.initial)) {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Try to load from cache first
    final cachedStats = await _cacheService.getCached<DashboardStats>(
      'dashboard_stats',
      (json) => DashboardStats.fromJson(json),
    );

    if (cachedStats != null) {
      state = state.copyWith(
        status: DataStatus.success,
        stats: cachedStats,
      );
    }

    // Fetch fresh data in background
    await refresh();
  }

  Future<void> refresh({DateTime? date}) async {
    state = state.copyWith(status: DataStatus.loading);

    try {
      final stats = await _dashboardService.getDashboardStats(date: date);
      final recentOrders = await _dashboardService.getRecentOrders();

      // Cache the results
      await _cacheService.cache('dashboard_stats', stats);

      state = state.copyWith(
        status: DataStatus.success,
        stats: stats,
        recentOrders: recentOrders,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return DashboardNotifier(dashboardService, cacheService);
});
