import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/features/website_customizer/data/website_service.dart';
import 'package:rockster/features/website_customizer/domain/website_models.dart';
import 'package:rockster/features/website_customizer/presentation/widgets/website_preview_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';

class WebsiteCustomizerScreen extends ConsumerStatefulWidget {
  const WebsiteCustomizerScreen({super.key});

  @override
  ConsumerState<WebsiteCustomizerScreen> createState() => _WebsiteCustomizerScreenState();
}

class _WebsiteCustomizerScreenState extends ConsumerState<WebsiteCustomizerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _headlineController;
  late TextEditingController _subheadlineController;
  late TextEditingController _btnTextController;

  // Service will be accessed via ref
  bool _isLoading = true;

  late WebsiteConfig _config;

  final List<Color> _brandColors = [
    const Color(0xFFD97706), // Amber (Default)
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Emerald
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Default config
    _config = WebsiteConfig(
      headline: 'Taste the Difference',
      subheadline: 'Experience culinary excellence in every bite.',
      primaryColor: const Color(0xFFD97706),
      heroImageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?q=80&w=600&auto=format&fit=crop',
      startButtonText: 'Order Now',
    );

    _headlineController = TextEditingController(text: _config.headline);
    _subheadlineController = TextEditingController(text: _config.subheadline);
    _btnTextController = TextEditingController(text: _config.startButtonText);

    _headlineController.addListener(() => _updateConfig());
    _subheadlineController.addListener(() => _updateConfig());
    _btnTextController.addListener(() => _updateConfig());

    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await ref.read(websiteServiceProvider).fetchConfig();
      if (config != null) {
        setState(() {
          _config = config;
          _headlineController.text = config.headline;
          _subheadlineController.text = config.subheadline;
          _btnTextController.text = config.startButtonText;
        });
      }
    } catch (e) {
      // Keep defaults on error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateConfig() {
    setState(() {
      _config = _config.copyWith(
        headline: _headlineController.text,
        subheadline: _subheadlineController.text,
        startButtonText: _btnTextController.text,
      );
    });
  }

  Future<void> _saveConfig() async {
    setState(() => _isLoading = true);
    try {
       await ref.read(websiteServiceProvider).updateConfig(_config);
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Website Published Successfully!')),
         );
         context.pop();
       }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error saving: $e')),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headlineController.dispose();
    _subheadlineController.dispose();
    _btnTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Website Customizer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Edit'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Editor Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Branding', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // Color Picker
                Text('Primary Color', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: _brandColors.map((color) {
                    final isSelected = _config.primaryColor.value == color.value;
                    return GestureDetector(
                      onTap: () => setState(() => _config = _config.copyWith(primaryColor: color)),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Text('Content', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Headline',
                  controller: _headlineController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Sub-headline',
                  controller: _subheadlineController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Button Text',
                  controller: _btnTextController,
                ),
                
                const SizedBox(height: 24),
                Text('Assets', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 32, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Change Hero Image', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Preview Tab
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(24),
            child: Center(
              child: WebsitePreviewWidget(config: _config),
            ),
          ),
        ],
      ),
    );
  }
}
