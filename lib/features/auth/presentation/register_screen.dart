import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimalist Text Logo
                Column(
                  children: [
                    Text(
                      'ROCKSTAR',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RESTAURANT ADMIN',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.black54,
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),

                Text(
                  'Join Rockstar',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        controller: _nameController,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Restaurant Name', // This might be optional or handled later, but keeping UI field
                        hint: "John's Burger Joint",
                        icon: Icons.store_outlined,
                        controller: _restaurantNameController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email Address',
                        hint: 'owner@restaurant.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v != null && v.contains('@')) ? null : 'Invalid email',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        isPassword: true,
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Terms Checkbox
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            fillColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppColors.gold;
                              }
                              return Colors.black12;
                            }),
                            checkColor: MaterialStateProperty.all(Colors.white),
                            side: const BorderSide(color: Colors.black26),
                          ),
                        ),
                        child: CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                          title: Row(
                            children: [
                              const Text("I accept the ", style: TextStyle(color: Colors.black54, fontSize: 13)),
                              GestureDetector(
                                onTap: _showTermsDialog,
                                child: const Text(
                                  "Terms & Conditions",
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.gold.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                )
                              : const Text(
                                  'CREATE ACCOUNT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Sign In'),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: AppColors.gold),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.black45,
              ),
              onPressed: onTogglePassword,
            )
          : null,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
