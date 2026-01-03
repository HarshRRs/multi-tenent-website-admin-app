import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
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
  bool _obscurePassword = true; // State for password visibility

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
          if (next.error!.contains('DioException') || next.error!.contains('connection')) {
             errorMessage = 'Network Error: Cannot connect to server. Please check your internet.';
          } else if (next.error!.contains('401')) {
             errorMessage = 'Invalid Email or Password';
          } else {
             errorMessage = next.error!;
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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Brand area
                // Logo/Brand area
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                
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
                          'Welcome Back',
                          style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your restaurant dashboard',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Email Address',
                          hint: 'owner@restaurant.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!value.contains('@')) return 'Please enter a valid email';
                            return null;
                          },
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
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Sign In',
                          isLoading: isLoading,
                          onPressed: _handleLogin,
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
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        'Create Account',
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
