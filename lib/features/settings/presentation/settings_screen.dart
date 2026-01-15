import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
import 'package:rockster/core/providers/locale_provider.dart';
import 'package:rockster/features/settings/presentation/printer_settings_screen.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;
    
    _nameController.text = user.name;
    _addressController.text = user.address;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authNotifierProvider.notifier).updateProfile(
                  _nameController.text,
                  _addressController.text,
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Handle error
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final restaurantName = user?.name ?? 'Cosmos Diner';
    final address = user?.address.isNotEmpty == true ? user!.address : 'Add address...';
    
    // Localization - hardcoded for now
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.cloudDancer,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            title: Text(
              'Settings',
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
                // Profile Section with Floral Background
                ModernCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/flower_background.jpg'),
                        fit: BoxFit.cover,
                        opacity: 0.15, // Subtle floral effect
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.burntTerracotta,
                          child: Text(
                            restaurantName.isNotEmpty ? restaurantName[0].toUpperCase() : 'C',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurantName,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepInk,
                                ),
                              ),
                              Text(
                                address,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.burntTerracotta),
                          onPressed: _showEditProfileDialog,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('PREFERENCES'),
                _buildSettingTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage alerts and sounds',
                ),
                _buildSettingTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: currentLocale.languageCode == 'en' ? 'English (US)' : 'Français',
                  onTap: () {
                     // Toggle Language
                     final newLocale = currentLocale.languageCode == 'en' 
                        ? const Locale('fr') 
                        : const Locale('en');
                     ref.read(localeProvider.notifier).setLocale(newLocale);
                  },
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('HARDWARE'),
                _buildSettingTile(
                  icon: Icons.print_outlined,
                  title: 'Printer Setup',
                  subtitle: 'Epson TM Series / ESC/POS',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrinterSettingsScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('ACCOUNT'),
                 _buildSettingTile(
                  icon: Icons.logout,
                   title: 'Sign Out',
                   subtitle: 'Log out of your account',
                   onTap: () {
                     ref.read(authNotifierProvider.notifier).logout();
                     context.go('/login');
                   },
                   isDestructive: true,
                 ),
                 
                 const SizedBox(height: 100),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive 
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.burntTerracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.burntTerracotta,
              size: 20,
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
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.deepInk,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing
          else Icon(Icons.chevron_right, color: AppColors.softBorder),
        ],
      ),
    );
  }
}
