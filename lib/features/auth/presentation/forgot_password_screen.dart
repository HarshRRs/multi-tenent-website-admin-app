import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/core/providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _email;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Add timeout to prevent infinite loading
      await ref.read(authServiceProvider).forgotPassword(email)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out. Please try again.');
      });
      
      if (mounted) {
        setState(() {
          _codeSent = true;
          _email = email;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset code sent! Please check your email inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage = 'An error occurred';
        if (e.toString().contains('timeout')) {
          errorMessage = 'Request timed out. Please check your connection and try again.';
        } else if (e.toString().contains('SocketException') || e.toString().contains('connection')) {
          errorMessage = 'Could not connect to server. Please check your internet.';
        } else {
          errorMessage = e.toString().replaceAll('Exception:', '').trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;

    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the code and new password')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await ref.read(authServiceProvider).resetPassword(
        email: _email!,
        code: code,
        newPassword: newPassword,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully! You can now login.')),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
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
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset, size: 64, color: AppColors.primaryLight),
                  const SizedBox(height: 24),
                  Text(
                    _codeSent ? 'Enter Reset Code' : 'Reset Password',
                    style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _codeSent 
                      ? 'Enter the 6-digit code sent to your email and your new password.'
                      : 'Enter your email address and we will send you a code to reset your password.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (!_codeSent) ...[
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'owner@restaurant.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Send Reset Code',
                      isLoading: _isLoading,
                      onPressed: _sendResetCode,
                    ),
                  ] else ...[
                    CustomTextField(
                      label: 'Reset Code',
                      hint: '123456',
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      controller: _codeController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'New Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _newPasswordController,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Reset Password',
                      isLoading: _isLoading,
                      onPressed: _resetPassword,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _codeSent = false),
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
