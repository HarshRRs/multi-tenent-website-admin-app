import 'package:rockster/features/payments/domain/payment_models.dart';

// Transactions
List<Transaction> transactionsFromJson(List<dynamic> json) {
  return json.map((e) => transactionFromJson(e)).toList();
}

Transaction transactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    id: json['id'] ?? '',
    customerName: json['customerName'] ?? 'Unknown',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    status: _parseTransactionStatus(json['status']),
    paymentMethod: json['paymentMethod'] ?? 'Unknown Method',
  );
}

TransactionStatus _parseTransactionStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
    case 'succeeded':
      return TransactionStatus.completed;
    case 'pending':
    case 'processing':
      return TransactionStatus.pending;
    case 'failed':
      return TransactionStatus.failed;
    case 'refunded':
      return TransactionStatus.refunded;
    default:
      return TransactionStatus.completed;
  }
}

// Stripe Connection Status
class StripeStatus {
  final bool isConnected;
  final String? accountId;
  final double availableBalance;
  final double pendingBalance;

  StripeStatus({
    required this.isConnected,
    this.accountId,
    required this.availableBalance,
    required this.pendingBalance,
  });

  factory StripeStatus.fromJson(Map<String, dynamic> json) {
    return StripeStatus(
      isConnected: json['isConnected'] ?? false,
      accountId: json['accountId'],
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
