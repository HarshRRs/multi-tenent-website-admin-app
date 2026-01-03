import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text('John Doe', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Owner • Rockster App', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _buildSettingsTile(
            context,
            icon: Icons.payment,
            title: 'Payments & Payouts',
            subtitle: 'Stripe Connect, Transaction History',
            route: '/payments',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'Website Customizer',
            subtitle: 'Customize your public site',
            route: '/website-customizer',
          ),
           _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage alerts and push notifications',
            route: '/notifications',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences, printer setup',
            route: '/settings',
          ),
          
          const Divider(height: 32),
          
          _buildSettingsTile(
            context,
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

  Widget _buildSettingsTile(
    BuildContext context, {
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
      onTap: () {
        if (route == '/login') {
           // Clear state/auth logic here
           context.go(route);
        } else {
           context.push(route);
        }
      },
    );
  }
}
