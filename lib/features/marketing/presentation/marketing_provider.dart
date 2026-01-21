import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/marketing/data/marketing_service.dart';
import 'package:rockster/features/marketing/domain/marketing_models.dart';

final marketingServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketingService(apiClient);
});

final marketingProvider = StateNotifierProvider<MarketingNotifier, MarketingState>((ref) {
  final service = ref.watch(marketingServiceProvider);
  return MarketingNotifier(service);
});

class MarketingState {
  final List<Coupon> coupons;
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  MarketingState({
    this.coupons = const [],
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  MarketingState copyWith({
    List<Coupon>? coupons,
    List<Review>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return MarketingState(
      coupons: coupons ?? this.coupons,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MarketingNotifier extends StateNotifier<MarketingState> {
  final MarketingService _service;

  MarketingNotifier(this._service) : super(MarketingState());

  Future<void> loadCoupons() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final coupons = await _service.getCoupons();
      state = state.copyWith(coupons: coupons, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCoupon(Map<String, dynamic> data) async {
      await _service.createCoupon(data);
      await loadCoupons();
  }

  Future<void> toggleCoupon(String id, bool isActive) async {
    try {
      await _service.toggleCoupon(id, isActive);
      state = state.copyWith(
        coupons: state.coupons.map((c) => c.id == id 
          ? Coupon(
              id: c.id, 
              code: c.code, 
              discountType: c.discountType, 
              discountValue: c.discountValue, 
              minOrderAmount: c.minOrderAmount, 
              expiresAt: c.expiresAt, 
              isActive: isActive, 
              createdAt: c.createdAt
            ) 
          : c
        ).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCoupon(String id) async {
    await _service.deleteCoupon(id);
    await loadCoupons();
  }

  Future<void> loadReviews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reviews = await _service.getManagerReviews();
      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveReview(String id) async {
    await _service.approveReview(id);
    await loadReviews();
  }

  Future<void> deleteReview(String id) async {
    await _service.deleteReview(id);
    await loadReviews();
  }
}
