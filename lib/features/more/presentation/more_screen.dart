import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/core/providers/providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: AppColors.primaryLight),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'User', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${user?.role ?? "User"} • Rockster App', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildSettingsTile(
            context,
            ref,
            icon: Icons.payment,
            title: 'Payments & Payouts',
            subtitle: 'Stripe Connect, Transaction History',
            route: '/payments',
          ),
          _buildSettingsTile(
            context,
            ref,
            icon: Icons.language,
            title: 'Website Customizer',
            subtitle: 'Customize your public site',
            route: '/website-customizer',
          ),
           _buildSettingsTile(
            context,
            ref,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage alerts and push notifications',
            route: '/notifications',
          ),
          _buildSettingsTile(
            context,
            ref,
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences, printer setup',
            route: '/settings',
          ),
          
          const Divider(height: 32),
          
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.surfaceLight,
              child: Icon(Icons.network_check, color: AppColors.primaryLight),
            ),
            title: Text('Test Connection', style: AppTextStyles.labelLarge),
            subtitle: Text('Verify server availability', style: AppTextStyles.bodyMedium),
            onTap: () => _testConnection(context, ref),
          ),

          _buildSettingsTile(
            context,
            ref,
            icon: Icons.logout,
            title: 'Log Out',
            subtitle: 'Sign out of your account',
            route: '/login', // Will need proper logout logic later
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
    final dio = ref.read(apiClientProvider).dio;
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await dio.get('/');
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Success'),
            content: Text('Successfully connected to:\n$baseUrl\n\nStatus: ${response.data['status']}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Failed'),
            content: Text('Could not reach:\n$baseUrl\n\nError: $e'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  Widget _buildSettingsTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primaryLight,
        ),
      ),
      title: Text(title, style: AppTextStyles.labelLarge.copyWith(color: isDestructive ? AppColors.error : null)),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
      onTap: () async {
        if (route == '/login') {
           // Real logout logic
           await ref.read(authNotifierProvider.notifier).logout();
           if (context.mounted) {
             context.go(route);
           }
        } else {
           context.push(route);
        }
      },
    );
  }
}
