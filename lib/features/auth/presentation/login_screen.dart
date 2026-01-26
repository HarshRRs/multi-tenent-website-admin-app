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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/');
      } else if (next.status == AuthStatus.error) {
        String errorMessage = 'Authentication failed';

        if (next.error != null) {
          final errorLower = next.error!.toLowerCase();
          
          if (errorLower.contains('connection timeout') || 
              errorLower.contains('no internet') || 
              errorLower.contains('connection error')) {
             errorMessage = 'Network Error: Cannot connect to server';
          } else if (errorLower.contains('401') || errorLower.contains('400')) {
             errorMessage = 'Invalid Email or Password';
          } else {
             errorMessage = next.error!.replaceAll('Exception:', '').trim();
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Glowing COSMOS title - CENTERED (no hero image)
                    const GlowingText(
                      text: 'COSMOS',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                      glowColor: Colors.cyan,
                      glowRadius: 28,
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    // BUSINESS ADMIN subtitle
                    Text(
                      'BUSINESS ADMIN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                    
                    const SizedBox(height: 56),
                    
                    // Welcome Back
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Sign in to manage your business',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Email Input
                    CosmicInputField(
                      label: 'Email Address',
                      hint: 'owner@business.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Password Input
                    CosmicInputField(
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white60,
                        ),
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    CosmicButton(
                      text: 'SIGN IN',
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 40),
                    
                    // New to Cosmos?
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New to Cosmos?  ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
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
