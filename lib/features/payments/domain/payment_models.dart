enum TransactionStatus {
  completed,
  pending,
  failed,
  refunded,
}

class Transaction {
  final String id;
  final String customerName;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String paymentMethod; // e.g., 'Visa ending in 4242'

  Transaction({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.status,
    required this.paymentMethod,
  });
}
