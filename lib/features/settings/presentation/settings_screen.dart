import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local state for "Edit" simulation
  String _restaurantName = 'Rockstar Diner';
  String _address = '123 Music Ave, Nashville, TN';
  String _phone = '+1 (555) 123-4567';
  bool _autoPrint = true;

  Future<void> _showEditDialog(String title, String currentValue, Function(String) onSave) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit \$title', style: AppTextStyles.headlineMedium),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new \$title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              onSave(controller.text);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('\$title updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            value: isDarkMode,
            onChanged: (val) => ref.read(isDarkModeProvider.notifier).state = val,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Restaurant Info'),
          _buildInfoTile(
            icon: Icons.store,
            title: 'Restaurant Name',
            value: _restaurantName,
            onTap: () => _showEditDialog('Restaurant Name', _restaurantName, (val) => setState(() => _restaurantName = val)),
          ),
          _buildInfoTile(
            icon: Icons.location_on,
            title: 'Address',
            value: _address,
            onTap: () => _showEditDialog('Address', _address, (val) => setState(() => _address = val)),
          ),
           _buildInfoTile(
            icon: Icons.phone,
            title: 'Phone',
            value: _phone,
            onTap: () => _showEditDialog('Phone', _phone, (val) => setState(() => _phone = val)),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Hardware & Printing'),
          _buildSwitchTile(
            context,
            icon: Icons.print,
            title: 'Auto-print Orders',
            subtitle: 'Print receipt when order arrives',
            value: _autoPrint,
            onChanged: (val) => setState(() => _autoPrint = val),
          ),
          _buildStatusTile(
            icon: Icons.wifi_tethering,
            title: 'Kitchen Printer',
            status: 'Connected',
            isGood: true,
          ),
           _buildStatusTile(
            icon: Icons.receipt_long,
            title: 'Receipt Printer',
            status: 'Offline',
            isGood: false,
          ),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('2.1.0 (Build 42)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
             color: AppColors.primaryLight.withValues(alpha: 0.1),
             shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryLight),
        ),
        title: Text(title, style: AppTextStyles.labelLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white, // In real app, use Theme color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: AppTextStyles.bodySmall),
        subtitle: Text(value, style: AppTextStyles.labelLarge),
        trailing: const Icon(Icons.edit, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required String title,
    required String status,
    required bool isGood,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: AppTextStyles.labelLarge),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isGood ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: AppTextStyles.labelSmall.copyWith(
              color: isGood ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
