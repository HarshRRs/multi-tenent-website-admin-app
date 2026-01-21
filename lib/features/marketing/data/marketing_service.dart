import 'package:rockster/core/api/api_client.dart';
import 'package:rockster/features/marketing/domain/marketing_models.dart';

class MarketingService {
  final ApiClient _apiClient;

  MarketingService(this._apiClient);

  // --- Coupons ---

  Future<List<Coupon>> getCoupons() async {
    final response = await _apiClient.get('/coupons');
    return (response.data as List).map((json) => Coupon.fromJson(json)).toList();
  }

  Future<Coupon> createCoupon(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/coupons', data: data);
    return Coupon.fromJson(response.data);
  }

  Future<Coupon> toggleCoupon(String id, bool isActive) async {
    final response = await _apiClient.patch('/coupons/$id/toggle', data: {'isActive': isActive});
    return Coupon.fromJson(response.data);
  }

  Future<void> deleteCoupon(String id) async {
    await _apiClient.delete('/coupons/$id');
  }

  // --- Reviews ---

  Future<List<Review>> getManagerReviews() async {
    final response = await _apiClient.get('/reviews/manager');
    return (response.data as List).map((json) => Review.fromJson(json)).toList();
  }

  Future<Review> approveReview(String id) async {
    final response = await _apiClient.patch('/reviews/$id/approve');
    return Review.fromJson(response.data);
  }

  Future<void> deleteReview(String id) async {
    await _apiClient.delete('/reviews/$id');
  }
}
