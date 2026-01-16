import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/payments/domain/payment_models.dart';
import 'package:rockster/features/payments/presentation/payments_provider.dart';
import 'package:intl/intl.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:google_fonts/google_fonts.dart';

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
  


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);
    final stripeStatus = state.stripeStatus;
    final transactions = state.transactions;
    final isLoading = state.status == DataStatus.loading && stripeStatus == null;
    final isConnected = stripeStatus?.isConnected ?? false;

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        backgroundColor: AppColors.cloudDancer,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Payments & Reports',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.deepInk),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepInk),
          onPressed: () => context.pop(),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.deepInk),
            onPressed: () => ref.read(paymentsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta))
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
                  color: AppColors.burntTerracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.burntTerracotta.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.burntTerracotta),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stripe is not configured. Please add your Stripe keys to the server environment to enable payments.',
                        style: GoogleFonts.inter(
                          color: AppColors.burntTerracotta,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Stripe Connect Card - Keeping Purple as it's Stripe's Brand, but modernizing shape
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (stripeStatus != null && !stripeStatus.stripeEnabled)
                      ? [Colors.grey[400]!, Colors.grey[500]!]
                      : [const Color(0xFF635BFF), const Color(0xFF5650D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24), // Modern rounded
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
                        style: GoogleFonts.inter(
                          fontSize: 22,
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
                            ? 'Your account is connected and ready to receive payouts.'
                            : 'Connect your Stripe account to start accepting payments securely.'),
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9)),
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
                            'Connected: ${stripeStatus?.accountId ?? "Unknown"}',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
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
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold)
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
                      true, // Is Primary
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceCard(
                      'Pending Payout',
                      '€${(stripeStatus?.pendingBalance ?? 0).toStringAsFixed(2)}',
                      false, // Is Secondary
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Recent Transactions
            Text(
              'Recent Transactions', 
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepInk
              ),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSecondaryLight.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text("No recent transactions", style: GoogleFonts.inter(color: AppColors.textSecondaryLight)),
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
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.deepInk),
                            ),
                            Text(
                              tx.paymentMethod, 
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '€${tx.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: tx.status == TransactionStatus.refunded ? AppColors.textSecondaryLight : AppColors.deepInk,
                              decoration: tx.status == TransactionStatus.refunded ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(tx.date),
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
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

  Widget _buildBalanceCard(String title, String amount, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.deepInk : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: AppColors.softBorder),
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
            style: GoogleFonts.inter(
              fontSize: 12, 
              color: isPrimary ? Colors.white70 : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount, 
            style: GoogleFonts.inter(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : AppColors.deepInk,
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
        return AppColors.burntTerracotta;
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
