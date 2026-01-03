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
    state = state.copyWith(status: DataStatus.loading);
    try {
      final url = await _service.connectStripe();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Stripe onboarding';
      }
      // We don't update state to success here, as the user needs to complete the flow on web.
      // Ideally, we'd poll or wait for a webhook/deep link.
      // For now, we just refresh after a delay or let the user pull-to-refresh.
      state = state.copyWith(status: DataStatus.success); 
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
    }
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return PaymentsNotifier(service);
});
