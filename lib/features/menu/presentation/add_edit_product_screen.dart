import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';
import 'package:rockster/features/menu/presentation/menu_provider.dart';
import 'package:rockster/features/menu/data/menu_service.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;
  final MenuItem? productExtra; // Passed from list

  const AddEditProductScreen({super.key, this.productId, this.productExtra});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  
  // Image handling
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];
  List<String> _currentImages = []; // URLs of existing images

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.productId != null) {
      final product = widget.productExtra ?? ref.read(menuProvider).products.firstWhere((p) => p.id == widget.productId, orElse: () => MenuItem(id: '', name: '', description: '', price: 0, imageUrl: '', isAvailable: false, categoryId: ''));
      
      if (product.id.isNotEmpty) {
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
        _selectedCategory = product.categoryId;
        
        // Load images
        if (product.images.isNotEmpty) {
            _currentImages = List.from(product.images);
        } else if (product.imageUrl.isNotEmpty) {
            _currentImages = [product.imageUrl];
        }
      }
    }
  }

  int get _maxImages {
      final user = ref.read(authNotifierProvider).user;
      final type = user?.businessType?.toLowerCase() ?? 'restaurant';
      return (type == 'restaurant') ? 1 : 4;
  }

  Future<void> _pickImage() async {
    final currentCount = _currentImages.length + _pickedImages.length;
    final limit = _maxImages;

    if (currentCount >= limit) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maximum $limit images allowed for your business type.')));
        return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImages.add(image);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _removeImage(int index, bool isExisting) {
      setState(() {
          if (isExisting) {
              _currentImages.removeAt(index);
          } else {
              _pickedImages.removeAt(index);
          }
      });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        List<String> finalImages = List.from(_currentImages);

        // 1. Upload new videos
        if (_pickedImages.isNotEmpty) {
            final menuService = ref.read(menuServiceProvider);
            for (var img in _pickedImages) {
                final url = await menuService.uploadImage(img);
                finalImages.add(url);
            }
        }

        String mainImageUrl = finalImages.isNotEmpty ? finalImages.first : '';

        // 2. Create Object
        final product = MenuItem(
            id: widget.productId ?? '', 
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategory!,
            imageUrl: mainImageUrl, // Backward compatibility
            images: finalImages,    // Multi-image support
            isAvailable: true,
        );

        // 3. Call Notifier
        if (widget.productId == null) {
            await ref.read(menuProvider.notifier).addProduct(product);
        } else {
            await ref.read(menuProvider.notifier).updateProduct(product);
        }

        if (mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(widget.productId == null ? 'Product Added!' : 'Product Updated!')),
            );
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         }
      } finally {
         if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _handleDelete() async {
      if (widget.productId == null) return;
      setState(() => _isLoading = true);
      try {
          await ref.read(menuProvider.notifier).deleteProduct(widget.productId!);
          if (mounted) context.pop();
      } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;
    final maxImages = _maxImages;
    final currentCount = _currentImages.length + _pickedImages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Gallery / Picker
              Text('Images ($currentCount/$maxImages)', style: AppTextStyles.labelMedium.copyWith(color: AppColors.deepInk)),
              const SizedBox(height: 12),
              
              SizedBox(
                  height: 120,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                          // Add Button
                          if (currentCount < maxImages)
                            GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                    ),
                                    child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.add_a_photo, color: AppColors.primaryLight),
                                            SizedBox(height: 4),
                                            Text('Add', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                        ],
                                    ),
                                ),
                            ),

                          // Existing Images
                          ..._currentImages.asMap().entries.map((entry) {
                              return _buildImageItem(
                                  child: Image.network(entry.value, fit: BoxFit.cover),
                                  onDelete: () => _removeImage(entry.key, true),
                              );
                          }),

                          // New Images
                          ..._pickedImages.asMap().entries.map((entry) {
                              return _buildImageItem(
                                  child: kIsWeb 
                                    ? Image.network(entry.value.path, fit: BoxFit.cover) 
                                    : Image.file(File(entry.value.path), fit: BoxFit.cover),
                                  onDelete: () => _removeImage(entry.key, false),
                              );
                          }),
                      ],
                  ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Product Name',
                hint: 'e.g., Truffle Burger',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Description',
                hint: 'Ingredients and details...',
                controller: _descriptionController,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price',
                      hint: '0.00',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.euro,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category', style: AppTextStyles.labelMedium.copyWith(color: AppColors.deepInk)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              hint: const Text('Select'),
                              items: categories.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Product',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
              
              if (isEditing) ...[
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Delete Product',
                  isOutlined: true,
                  onPressed: _handleDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem({required Widget child, required VoidCallback onDelete}) {
      return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Stack(
              fit: StackFit.expand,
              children: [
                  child,
                  Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.red),
                          ),
                      ),
                  ),
              ],
          ),
      );
  }
}
