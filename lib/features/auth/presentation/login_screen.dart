import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Title
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
                    
                    const SizedBox(height: 12),
                    
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
                    
                    const SizedBox(height: 56),
                    
                    // Welcome Back
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Sign in to manage your business',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Email Input
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'owner@business.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'SIGN IN',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),
                    
                    const SizedBox(height: 40),
                    
                    // New to Cosmos?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to Cosmos? ',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
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
