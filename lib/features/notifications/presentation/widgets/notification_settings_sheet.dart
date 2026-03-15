import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_bite/core/services/sound_service.dart';
import 'package:event_bite/core/theme/app_colors.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  final SoundService _soundService = SoundService();
  SoundSource _currentSource = SoundSource.system;
  String? _customPath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final source = await _soundService.getSoundSource();
    final path = await _soundService.getCustomSoundPath();
    setState(() {
      _currentSource = source;
      _customPath = path;
    });
  }

  Future<void> _updateSource(SoundSource source) async {
    await _soundService.setSoundSource(source);
    setState(() {
      _currentSource = source;
    });
  }

  Future<void> _pickSound() async {
    await _soundService.pickCustomSound();
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notification Sound',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepInk,
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          _buildOption(
            title: 'System Default',
            subtitle: 'Use the device notification sound',
            value: SoundSource.system,
            icon: Icons.notifications_active,
          ),
          const SizedBox(height: 12),
          _buildOption(
            title: 'Custom Sound',
            subtitle: _customPath != null 
              ? 'Selected: ${_customPath!.split(RegExp(r'[/\\]')).last}' 
              : 'Choose a custom audio file',
            value: SoundSource.custom,
            icon: Icons.music_note,
            onTapTrailing: _pickSound,
          ),
          const SizedBox(height: 12),
          _buildOption(
            title: 'Silent',
            subtitle: 'No sound for orders',
            value: SoundSource.off,
            icon: Icons.notifications_off,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                _soundService.testSound();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Current Sound'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.burntTerracotta,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required SoundSource value,
    required IconData icon,
    VoidCallback? onTapTrailing,
  }) {
    final isSelected = _currentSource == value;
    
    return InkWell(
      onTap: () => _updateSource(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.burntTerracotta : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.burntTerracotta.withAlpha(10) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.burntTerracotta : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
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
                      color: AppColors.deepInk,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (value == SoundSource.custom && isSelected)
              IconButton(
                icon: const Icon(Icons.folder_open, color: AppColors.burntTerracotta),
                onPressed: onTapTrailing,
              ),
            if (isSelected && value != SoundSource.custom)
              const Icon(Icons.check_circle, color: AppColors.burntTerracotta),
          ],
        ),
      ),
    );
  }
}
