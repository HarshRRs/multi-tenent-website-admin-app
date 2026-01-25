import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/cosmic_background.dart';
import 'package:rockster/core/components/glowing_text.dart';
import 'package:rockster/core/components/cosmic_input_field.dart';
import 'package:rockster/core/components/cosmic_button.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  String _businessType = 'restaurant';
  
  static const String _termsText = '''Terms of Service: Cosmos Admin Platform
Last Updated: January 2026

1. The Service
Cosmos Admin provides a multi-tenant management system for businesses.

2. Subscription & Fees
Monthly fee: €48.00. No commissions on your sales.

3. Payments
Direct payouts via Stripe Connect to your account.

4. Liability
Cosmos Admin is not liable for service interruptions or customer disputes.

5. Termination
Cancel anytime. Data export available for 30 days after cancellation.''';

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white)),
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Text(_termsText, style: const TextStyle(color: Colors.white70)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You must accept the Terms & Conditions'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      await ref.read(authNotifierProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            businessType: _businessType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Registration failed'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: CosmicBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Glowing COSMOS title (no hero image)
                    const GlowingText(
                      text: 'COSMOS',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                      glowColor: Colors.cyan,
                      glowRadius: 26,
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 10),
                    
                    // BUSINESS ADMIN
                    Text(
                      'BUSINESS ADMIN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                    
                    const SizedBox(height: 44),
                    
                    // Join Cosmos
                    Text(
                      'Join Cosmos',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    
                    const SizedBox(height: 6),
                    
                    // Create account
                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 36),
                    
                    // Full Name
                    CosmicInputField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Business Type Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _businessType,
                        dropdownColor: const Color(0xFF1a1f3a),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Business Type',
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.business_center_outlined, color: Colors.cyan),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'restaurant', child: Text('🍛 Restaurant / Cafe')),
                          DropdownMenuItem(value: 'retail', child: Text('🛍️ Retail / Grocery')),
                          DropdownMenuItem(value: 'service', child: Text('💐 Service / Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _businessType = val);
                        },
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Business Name
                    CosmicInputField(
                      label: 'Business Name',
                      hint: 'My Awesome Store',
                      icon: Icons.store_outlined,
                      controller: _businessNameController,
                      autofillHints: const [AutofillHints.organizationName],
                      textInputAction: TextInputAction.next,
                    ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Email
                    CosmicInputField(
                      label: 'Email Address',
                      hint: 'owner@business.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v != null && v.contains('@')) ? null : 'Invalid email',
                    ).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Password
                    CosmicInputField(
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white60,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                    ).animate().fadeIn(duration: 500.ms, delay: 900.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 18),
                    
                    // Terms Checkbox
                    Center(
                      child: CheckboxListTile(
                        value: _acceptedTerms,
                        onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                        checkColor: Colors.black,
                        activeColor: Colors.cyan,
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('I accept the ', style: TextStyle(color: Colors.white, fontSize: 13)),
                            GestureDetector(
                              onTap: _showTermsDialog,
                              child: const Text(
                                'Terms',
                                style: TextStyle(
                                  color: Colors.cyan,
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
                    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
                    
                    const SizedBox(height: 28),
                    
                    // Create Account Button
                    CosmicButton(
                      text: 'CREATE ACCOUNT',
                      onPressed: _handleRegister,
                      isLoading: isLoading,
                    ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 28),
                    
                    // Already have account
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?  ',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
