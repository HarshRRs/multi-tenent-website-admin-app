import 'package:dio/dio.dart';
import 'package:rockster/features/payments/data/payment_dto.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  Future<StripeStatus> getStripeStatus() async {
    final response = await _dio.get('/payments/stripe/status');
    return StripeStatus.fromJson(response.data);
  }

  Future<String> connectStripe() async {
    final response = await _dio.post('/payments/stripe/connect');
    return response.data['url']; // Returns the onboarding URL
  }

  Future<List<Transaction>> getTransactions() async {
    final response = await _dio.get('/payments/transactions');
    return transactionsFromJson(response.data);
  }
}
