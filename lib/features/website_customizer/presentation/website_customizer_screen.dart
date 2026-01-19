import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/modern_card.dart';
// import 'package:rockster/features/website_customizer/data/website_service.dart';
import 'package:rockster/features/website_customizer/domain/website_models.dart';
import 'package:rockster/features/website_customizer/presentation/widgets/website_preview_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);
      
      try {
        final File file = File(image.path);
        final String imageUrl = await ref.read(websiteServiceProvider).uploadImage(file);
        
        setState(() {
          _config = _config.copyWith(heroImageUrl: imageUrl);
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Image uploaded successfully!')),
           );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
       // helper for picker error
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking image: $e')),
          );
        }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta)));
    }

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        title: Text(
          'Website Customizer',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.deepInk),
        ),
        backgroundColor: AppColors.cloudDancer,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepInk),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: Text(
              'Publish',
              style: GoogleFonts.inter(
                color: AppColors.burntTerracotta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.burntTerracotta,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.burntTerracotta,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Branding'),
                const SizedBox(height: 12),
                
                ModernCard(
                  child: Column(
                    children: [
                      // Color Picker
                      Text('Primary Color', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.deepInk)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _brandColors.map((color) {
                            final isSelected = _config.primaryColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => _config = _config.copyWith(primaryColor: color)),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                                  ] : null,
                                ),
                                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                _buildSectionTitle('Content'),
                const SizedBox(height: 12),

                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        'Delivery Radius: ${_config.deliveryRadiusKm.toStringAsFixed(1)} km',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.deepInk),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _config.primaryColor,
                          inactiveTrackColor: AppColors.softBorder,
                          thumbColor: _config.primaryColor,
                          overlayColor: _config.primaryColor.withValues(alpha: 0.2),
                          valueIndicatorColor: _config.primaryColor,
                          valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                        ),
                        child: Slider(
                          value: _config.deliveryRadiusKm,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          label: '${_config.deliveryRadiusKm.toStringAsFixed(1)} km',
                          onChanged: (value) {
                             setState(() {
                               _config = _config.copyWith(deliveryRadiusKm: value);
                             });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Assets'),
                const SizedBox(height: 12),
                
                ModernCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.softBorder, style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                           image: NetworkImage(_config.heroImageUrl),
                           fit: BoxFit.cover,
                           colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                        )
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 32, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              'Change Hero Image', 
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),

          // Preview Tab
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(24),
            child: Center(
              child: WebsitePreviewWidget(config: _config),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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
}
