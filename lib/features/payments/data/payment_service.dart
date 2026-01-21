import 'package:dio/dio.dart';
import 'package:rockster/features/payments/data/payment_dto.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  Future<String> getStripePublishableKey() async {
    final response = await _dio.get('payments/config');
    return response.data['publishableKey'];
  }

  Future<Map<String, dynamic>> createPaymentIntent(double amount, String currency) async {
    final response = await _dio.post(
      'payments/create-payment-intent',
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data; // { clientSecret: '...' }
  }

  Future<StripeStatus> getStripeStatus() async {
    try {
      final response = await _dio.get('payments/account');
      return StripeStatus.fromJson(response.data);
    } catch (e) {
      // If error (e.g. 503), return default disconnected status
      return StripeStatus(isConnected: false, availableBalance: 0, pendingBalance: 0);
    }
  }

  Future<String> connectStripe() async {
    final response = await _dio.post(
      'payments/create-connected-account',
    );
    return response.data['url'] as String;
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _dio.get('payments/transactions');
      return transactionsFromJson(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<String> getDashboardLink() async {
    final response = await _dio.get('payments/dashboard-link');
    return response.data['url'] as String;
  }
}
