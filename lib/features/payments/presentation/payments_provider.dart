import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/payments/data/payment_dto.dart';
import 'package:rockster/features/payments/data/payment_service.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';
import 'package:url_launcher/url_launcher.dart';

enum DataStatus { initial, loading, success, error }

class PaymentsState {
  final DataStatus status;
  final StripeStatus? stripeStatus;
  final List<Transaction> transactions;
  final String? error;
  final String? stripePublishableKey;

  PaymentsState({
    required this.status,
    this.stripeStatus,
    this.transactions = const [],
    this.error,
    this.stripePublishableKey,
  });

  PaymentsState copyWith({
    DataStatus? status,
    StripeStatus? stripeStatus,
    List<Transaction>? transactions,
    String? error,
    String? stripePublishableKey,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      stripeStatus: stripeStatus ?? this.stripeStatus,
      transactions: transactions ?? this.transactions,
      error: error ?? this.error,
      stripePublishableKey: stripePublishableKey ?? this.stripePublishableKey,
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
    state = state.copyWith(status: DataStatus.loading);
    try {
      final url = await _service.connectStripe();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        state = state.copyWith(
          status: DataStatus.error,
          error: "Could not open Stripe onboarding URL",
        );
      }
      state = state.copyWith(status: DataStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: "Failed to connect Stripe: ${e.toString()}",
      );
    }
  }

  Future<void> initStripe() async {
    try {
      final key = await _service.getStripePublishableKey();
      state = state.copyWith(stripePublishableKey: key);
    } catch (e) {
      // Stripe config not available - not critical
    }
  }

  Future<void> processPayment(double amount, String currency) async {
    state = state.copyWith(status: DataStatus.loading);
    try {
      // Payment processing disabled - flutter_stripe removed due to build issues
      state = state.copyWith(
        status: DataStatus.error,
        error: "Stripe payments temporarily disabled. Add flutter_stripe SDK to enable.",
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
