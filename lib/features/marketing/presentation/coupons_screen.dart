import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/marketing/presentation/marketing_provider.dart';
import 'package:intl/intl.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketingProvider.notifier).loadCoupons());
  }

  void _showAddCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCouponDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons & Discounts'),
      ),
      body: state.isLoading && state.coupons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(marketingProvider.notifier).loadCoupons(),
              child: state.coupons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No coupons created yet', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: CustomButton(
                              text: 'Create First Coupon',
                              onPressed: _showAddCouponDialog,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = state.coupons[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(coupon.code, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryLight)),
                                const Spacer(),
                                Switch(
                                  value: coupon.isActive,
                                  onChanged: (val) => ref.read(marketingProvider.notifier).toggleCoupon(coupon.id, val),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${coupon.discountType == "PERCENT" ? "${coupon.discountValue}%" : "€${coupon.discountValue}"} Discount',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Min. Order: €${coupon.minOrderAmount}'),
                                if (coupon.expiresAt != null)
                                  Text('Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expiresAt!)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _confirmDelete(coupon.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: state.coupons.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddCouponDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: const Text('Are you sure you want to delete this coupon?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(marketingProvider.notifier).deleteCoupon(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddCouponDialog extends ConsumerStatefulWidget {
  const AddCouponDialog({super.key});

  @override
  ConsumerState<AddCouponDialog> createState() => _AddCouponDialogState();
}

class _AddCouponDialogState extends ConsumerState<AddCouponDialog> {
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  final _minAmountController = TextEditingController(text: '0');
  String _discountType = 'PERCENT';
  DateTime? _expiryDate;

  Future<void> _save() async {
    if (_codeController.text.isEmpty || _valueController.text.isEmpty) return;

    try {
      await ref.read(marketingProvider.notifier).createCoupon({
        'code': _codeController.text,
        'discountType': _discountType,
        'discountValue': double.parse(_valueController.text),
        'minOrderAmount': double.parse(_minAmountController.text),
        'expiresAt': _expiryDate?.toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Coupon'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Coupon Code',
              hint: 'e.g., WELCOME10',
              controller: _codeController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _discountType,
              decoration: const InputDecoration(labelText: 'Discount Type'),
              items: const [
                DropdownMenuItem(value: 'PERCENT', child: Text('Percentage (%)')),
                DropdownMenuItem(value: 'FIXED', child: Text('Fixed Amount (€)')),
              ],
              onChanged: (val) => setState(() => _discountType = val!),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Discount Value',
              hint: 'e.g., 10',
              controller: _valueController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Min. Order Amount',
              hint: '0',
              controller: _minAmountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiry Date (Optional)'),
              subtitle: Text(_expiryDate == null ? 'None' : DateFormat('MMM dd, yyyy').format(_expiryDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _expiryDate = date);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
