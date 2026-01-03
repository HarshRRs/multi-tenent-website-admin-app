import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';
import 'package:rockster/features/payments/presentation/payments_provider.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentsProvider.notifier).refresh();
      ref.read(paymentsProvider.notifier).initStripe();
    });
  }

  void _handleConnectStripe() {
    ref.read(paymentsProvider.notifier).connectStripe();
  }
  
  Future<void> _handlePayment() async {
      try {
          await ref.read(paymentsProvider.notifier).processPayment(10.00, 'EUR');
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful!'), backgroundColor: AppColors.success),
              );
          }
      } catch (e) {
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Failed: $e'), backgroundColor: AppColors.error),
              );
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);
    final stripeStatus = state.stripeStatus;
    final transactions = state.transactions;
    final isLoading = state.status == DataStatus.loading && stripeStatus == null;
    final isConnected = stripeStatus?.isConnected ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(paymentsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Payment Terminal (Test)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                   const Icon(Icons.point_of_sale, size: 32, color: AppColors.primaryLight),
                   const SizedBox(width: 16),
                   Expanded(
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Text('Payment Terminal', style: AppTextStyles.headlineSmall),
                               Text('Simulate a card payment', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight)),
                           ],
                       ),
                   ),
                   FilledButton.icon(
                       onPressed: _handlePayment, 
                       icon: const Icon(Icons.credit_card), 
                       label: const Text('Charge €10.00'),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stripe Connect Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF635BFF), Color(0xFF5650D8)], // Stripe Blurple
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF635BFF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Stripe Connect',
                        style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isConnected
                        ? 'Your account is connected and ready to receive payouts.'
                        : 'Connect your Stripe account to start accepting payments securely.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Connected: \${stripeStatus?.accountId ?? "Unknown"}',
                            style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.status == DataStatus.loading ? null : _handleConnectStripe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF635BFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state.status == DataStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('Connect with Stripe', style: AppTextStyles.labelLarge),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Balance Overview (Only if connected)
            if (isConnected) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Available Balance',
                      '€\${(stripeStatus?.availableBalance ?? 0).toStringAsFixed(2)}',
                      Colors.white,
                      AppColors.textDark
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Pending Payout',
                      '€\${(stripeStatus?.pendingBalance ?? 0).toStringAsFixed(2)}',
                      AppColors.surfaceLight,
                      AppColors.textSecondaryLight
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions
            Text('Recent Transactions', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(child: Text("No recent transactions"))
            else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(tx.status).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(tx.status),
                          color: _getStatusColor(tx.status),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.customerName, style: AppTextStyles.labelLarge),
                            Text(tx.paymentMethod, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '€\${tx.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: tx.status == TransactionStatus.refunded ? AppColors.textSecondaryLight : AppColors.textDark,
                              decoration: tx.status == TransactionStatus.refunded ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(tx.date),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Text(amount, style: AppTextStyles.headlineMedium.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.refunded:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Icons.arrow_downward;
      case TransactionStatus.pending:
        return Icons.access_time;
      case TransactionStatus.failed:
        return Icons.error_outline;
      case TransactionStatus.refunded:
        return Icons.keyboard_return;
    }
  }
}
