import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/l10n/app_localizations.dart';
import 'package:rockster/features/notifications/presentation/widgets/notification_settings_sheet.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userName = user?.name ?? "User";
    final userRole = user?.role ?? "Owner";

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.cloudDancer,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Menu',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppColors.deepInk,
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Modern Profile Card with Floral Background
                ModernCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/flower_background.jpg'),
                        fit: BoxFit.cover,
                        opacity: 0.15, // Subtle floral touch
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.burntTerracotta.withValues(alpha: 0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.burntTerracotta,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepInk,
                                ),
                              ),
                              Text(
                                '$userRole • Cosmos Admin',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                _buildSectionHeader('Marketing'),
                _buildMenuTile(
                  context,
                  icon: Icons.confirmation_number_outlined,
                  title: 'Coupons & Discounts',
                  subtitle: 'Create and manage promo codes',
                  onTap: () => context.push('/coupons'),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.rate_review_outlined,
                  title: 'Reviews Moderation',
                  subtitle: 'Approve or delete feedback',
                  onTap: () => context.push('/reviews'),
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('Management'),
                _buildMenuTile(
                  context,
                  icon: Icons.layers_outlined,
                  title: 'Floor Plan Designer',
                  subtitle: 'Arrange tables and layout',
                  onTap: () => context.push('/tables'),
                ),

                const SizedBox(height: 16),
                _buildSectionHeader(AppLocalizations.of(context)!.settingsGeneral.toUpperCase()),
                _buildMenuTile(
                  context,
                  icon: Icons.notifications_none_outlined,
                  title: AppLocalizations.of(context)!.settingsNotifications,
                  subtitle: 'Manage alerts and sounds',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const NotificationSettingsSheet(),
                    );
                  },
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.settings_outlined,
                  title: AppLocalizations.of(context)!.settingsTitle,
                  subtitle: 'App preferences, printer setup',
                  onTap: () => context.push('/settings'),
                ),
                
                const SizedBox(height: 16),
                _buildSectionHeader('Account'),
                _buildMenuTile(
                  context,
                  icon: Icons.logout_outlined,
                  title: AppLocalizations.of(context)!.settingsSignOut,
                  subtitle: 'Sign out of your account',
                  isDestructive: true,
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.burntTerracotta;
    
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.deepInk,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.softBorder,
          ),
        ],
      ),
    );
  }
}
