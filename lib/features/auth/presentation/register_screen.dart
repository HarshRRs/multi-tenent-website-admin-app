import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  
  static const String _termsText = '''
Terms of Service: Rockstar Admin Platform
Last Updated: January 2026

1. The Service
Rockstar Admin (the "Platform") provides a multi-tenant management system that allows Restaurant Owners ("Users") to manage menus, receive orders, and customize their provided web engine. By using our platform, you agree to these terms.

2. Subscription & Fees
Flat Monthly Fee: Access to the platform is granted for a recurring fee of €48.00 per month.

Billing: This fee is billed in advance every 30 days. Failure to pay will result in the temporary suspension of your website and admin access.

No Commissions: Rockstar Admin does not take a percentage of your sales. All revenue generated through your website (minus Stripe fees) belongs entirely to you.

3. Payments & Stripe Connect
Direct Payouts: Rockstar Admin uses Stripe Connect to facilitate payments. Money from your customers goes directly from the customer to your linked Stripe account.

Liability: Rockstar Admin is not responsible for delayed payouts, disputed charges (chargebacks), or technical issues within Stripe’s infrastructure.

Taxes: You are responsible for collecting and reporting all applicable taxes (VAT/Sales Tax) for the food sold through your website.

4. Use of the "Web Engine"
License: We grant you a limited license to use our universal web engine to host your restaurant’s menu and accept orders.

Content: You are responsible for all images, prices, and descriptions uploaded to your menu. You must own the rights to the photos you upload.

5. Limitation of Liability
Rockstar Admin is a software tool. We are not liable for:

Loss of revenue due to temporary internet outages or server downtime.

Mistakes in orders made by customers on your website.

Any health or safety issues related to the food prepared by your restaurant.

Maximum Liability: In any event, our total liability to you is limited to the amount of the last monthly subscription fee paid (€48.00).

6. Termination
Cancel Anytime: You can cancel your subscription at any time through the Admin App settings. Access will remain until the end of your current billing cycle.

Data Retrieval: Upon cancellation, you have 30 days to export your order history before the data is permanently deleted from our servers.

7. Modifications
We may update these terms to reflect new features. Continued use of the app after an update constitutes acceptance of the new terms.
''';

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Text(_termsText, style: AppTextStyles.bodyMedium),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _restaurantNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must accept the Terms & Conditions'), backgroundColor: AppColors.error),
          );
          return;
      }
      
      // Note: Restaurant Name is currently unused in the backend API
      await ref.read(authNotifierProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundDark, AppColors.secondaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Glass Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join Rockster',
                          style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start managing your restaurant today',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Restaurant Name',
                          hint: "John's Burger Joint",
                          prefixIcon: Icons.store_outlined,
                          controller: _restaurantNameController,
                          // Optional for now
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Email Address',
                          hint: 'owner@restaurant.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (v) => (v != null && v.contains('@')) ? null : 'Invalid email',
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Password',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textSecondaryLight,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                        ),
                        const SizedBox(height: 16),
                        
                        // Terms Checkbox
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.primaryLight;
                                }
                                return Colors.white;
                              }),
                              checkColor: MaterialStateProperty.all(Colors.white),
                            ),
                          ),
                          child: CheckboxListTile(
                            value: _acceptedTerms,
                            onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                            title: Row(
                              children: [
                                const Text("I accept the ", style: TextStyle(color: Colors.white70)),
                                GestureDetector(
                                  onTap: _showTermsDialog,
                                  child: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Create Account',
                          isLoading: isLoading,
                          onPressed: _handleRegister,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryLight),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
