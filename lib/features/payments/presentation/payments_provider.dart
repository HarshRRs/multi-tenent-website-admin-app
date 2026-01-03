import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/payments/data/payment_dto.dart';
import 'package:rockster/features/payments/data/payment_service.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

enum DataStatus { initial, loading, success, error }

class PaymentsState {
  final DataStatus status;
  final StripeStatus? stripeStatus;
  final List<Transaction> transactions;
  final String? error;

  PaymentsState({
    required this.status,
    this.stripeStatus,
    this.transactions = const [],
    this.error,
  });

  PaymentsState copyWith({
    DataStatus? status,
    StripeStatus? stripeStatus,
    List<Transaction>? transactions,
    String? error,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      stripeStatus: stripeStatus ?? this.stripeStatus,
      transactions: transactions ?? this.transactions,
      error: error ?? this.error,
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final PaymentService _service;

  PaymentsNotifier(this._service) : super(PaymentsState(status: DataStatus.initial)) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(status: DataStatus.loading);
    try {
      final results = await Future.wait([
        _service.getStripeStatus(),
        _service.getTransactions(),
      ]);

      state = state.copyWith(
        status: DataStatus.success,
        stripeStatus: results[0] as StripeStatus,
        transactions: results[1] as List<Transaction>,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  Future<void> connectStripe() async {
    // ... Simplified/Mocked for now as backend mock is removed
    state = state.copyWith(error: "Stripe Connect flow requires a hosted URL.");
  }

  Future<void> initStripe() async {
    try {
      final key = await _service.getStripePublishableKey();
      Stripe.publishableKey = key;
      await Stripe.instance.applySettings();
    } catch (e) {
      print("Stripe Init Error: $e");
    }
  }

  Future<void> processPayment(double amount, String currency) async {
    state = state.copyWith(status: DataStatus.loading);
    try {
      // 1. Create Payment Intent on Backend
      final data = await _service.createPaymentIntent(amount, currency);
      final clientSecret = data['clientSecret'];

      // 2. Init Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Rockster Restaurant',
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF635BFF),
            ),
          ),
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Success handling
      state = state.copyWith(
        status: DataStatus.success,
        // In a real app, we would verify status with backend here
      );
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return PaymentsNotifier(service);
});
