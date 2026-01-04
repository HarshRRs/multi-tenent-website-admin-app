import 'package:dio/dio.dart';
import 'package:rockster/features/payments/data/payment_dto.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  Future<String> getStripePublishableKey() async {
    final response = await _dio.get('/payments/config');
    return response.data['publishableKey'];
  }

  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    final response = await _dio.post(
      '/payments/create-payment-intent',
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data; // { clientSecret: '...' }
  }

  // Keep these for now, returning empty/default to avoid UI errors since I removed backend mocks
  Future<StripeStatus> getStripeStatus() async {
      return StripeStatus(isConnected: false, accountId: '', availableBalance: 0, pendingBalance: 0);
  }

  Future<String> connectStripe() async {
    throw UnimplementedError("Stripe Connect not fully implemented yet");
  }

  Future<List<Transaction>> getTransactions() async {
    return []; 
  }

  Future<String> verifyPaymentStatus(String paymentId) async {
    final response = await _dio.get('/payments/status/$paymentId');
    return response.data['status'];
  }
}
