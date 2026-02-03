import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Terms & Conditions', style: theme.textTheme.titleLarge),
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Text(_termsText, style: theme.textTheme.bodyMedium),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
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
            backgroundColor: Theme.of(context).colorScheme.error,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'COSMOS',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 10),
                    
                    Center(
                      child: Text(
                        'BUSINESS ADMIN',
                        style: theme.textTheme.labelLarge?.copyWith(
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                    
                    const SizedBox(height: 44),
                    
                    Text(
                      'Join Cosmos',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    
                    const SizedBox(height: 6),
                    
                    Text(
                      'Create your account',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 36),
                    
                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Business Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _businessType,
                      dropdownColor: theme.colorScheme.surface,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Business Type',
                        prefixIcon: Icon(Icons.business_center_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'restaurant', child: Text('🍛 Restaurant / Cafe')),
                        DropdownMenuItem(value: 'retail', child: Text('🛍️ Retail / Grocery')),
                        DropdownMenuItem(value: 'service', child: Text('💐 Service / Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _businessType = val);
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Business Name
                    TextFormField(
                      controller: _businessNameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.organizationName],
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        hintText: 'My Awesome Store',
                        prefixIcon: Icon(Icons.store_outlined),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'owner@business.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => (v != null && v.contains('@')) ? null : 'Invalid email',
                    ).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _handleRegister(),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 chars',
                    ).animate().fadeIn(duration: 500.ms, delay: 900.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 18),
                    
                    // Terms Checkbox
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                      checkColor: Colors.white,
                      activeColor: theme.colorScheme.primary,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('I accept the ', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13)),
                          GestureDetector(
                            onTap: _showTermsDialog,
                            child: Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
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
                    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
                    
                    const SizedBox(height: 28),
                    
                    // Create Account Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1100.ms).scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 28),
                    
                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 1200.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
