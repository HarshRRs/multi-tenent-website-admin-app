import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';
import 'package:rockster/features/payments/presentation/payments_provider.dart';
import 'package:intl/intl.dart';
import 'package:rockster/core/components/modern_card.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentsProvider.notifier).refresh();
      ref.read(paymentsProvider.notifier).initStripe();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when returning to app (e.g. after Stripe onboarding)
      ref.read(paymentsProvider.notifier).refresh();
    }
  }

  void _handleConnectStripe() {
    ref.read(paymentsProvider.notifier).connectStripe();
  }

  void _handleOpenDashboard() {
    ref.read(paymentsProvider.notifier).openStripeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);
    final stripeStatus = state.stripeStatus;
    final transactions = state.transactions;
    final isLoading = state.status == DataStatus.loading && stripeStatus == null;
    final isConnected = stripeStatus?.isConnected ?? false;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Payments & Reports',
          style: theme.textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
         actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: () => ref.read(paymentsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: AppColors.liquidAmber))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stripe Unconfigured Warning
            if (stripeStatus != null && !stripeStatus.stripeEnabled)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.liquidAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.liquidAmber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.liquidAmber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stripe is not configured. Please add your Stripe keys to the server environment to enable payments.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.liquidAmber,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Stripe Connect Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (stripeStatus != null && !stripeStatus.stripeEnabled)
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [const Color(0xFF635BFF), const Color(0xFF5650D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ((stripeStatus != null && !stripeStatus.stripeEnabled) ? Colors.grey : const Color(0xFF635BFF)).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Stripe Connect',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    (stripeStatus != null && !stripeStatus.stripeEnabled)
                        ? 'Payment service is currently disabled on the server.'
                        : (isConnected
                            ? 'Your account is connected and ready to receive payouts. Manage your details in the dashboard.'
                            : 'Connect your Stripe account to start accepting payments securely.'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isConnected)
                    Column(
                      children: [
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
                                'Connected',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: state.status == DataStatus.loading ? null : _handleOpenDashboard,
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Manage Stripe Dashboard'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (state.status == DataStatus.loading || (stripeStatus != null && !stripeStatus.stripeEnabled)) ? null : _handleConnectStripe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF635BFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: state.status == DataStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                (stripeStatus != null && !stripeStatus.stripeEnabled) ? 'Service Unavailable' : 'Connect with Stripe', 
                                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF635BFF))
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Balance Overview
            if (isConnected) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Available Balance',
                      '€${(stripeStatus?.availableBalance ?? 0).toStringAsFixed(2)}',
                      true,
                      theme, // Is Primary
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Pending Payout',
                      '€${(stripeStatus?.pendingBalance ?? 0).toStringAsFixed(2)}',
                      false,
                      theme, // Is Secondary
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions
            Text(
              'Recent Transactions', 
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text("No recent transactions", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              )
            else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ModernCard(
                  padding: const EdgeInsets.all(16),
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
                            Text(
                              tx.customerName, 
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              tx.paymentMethod, 
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '€${tx.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: tx.status == TransactionStatus.refunded ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface,
                              decoration: tx.status == TransactionStatus.refunded ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(tx.date),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, bool isPrimary, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? theme.colorScheme.primary : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPrimary ? theme.colorScheme.onPrimary.withValues(alpha: 0.8) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount, 
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.liquidAmber;
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
