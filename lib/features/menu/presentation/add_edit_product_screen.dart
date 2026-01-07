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
  XFile? _pickedFile;
  String? _currentImageUrl;

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
        _currentImageUrl = product.imageUrl;
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedFile = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
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
        String finalImageUrl = _currentImageUrl ?? '';

        // 1. Upload Image if new one picked
        if (_pickedFile != null) {
            final menuService = ref.read(menuServiceProvider); // Get service directly for upload
            finalImageUrl = await menuService.uploadImage(_pickedFile);
        }

        // 2. Create Object
        final product = MenuItem(
            id: widget.productId ?? '', // Empty for new
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategory!,
            imageUrl: finalImageUrl,
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text(
            'This action cannot be undone. Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(menuProvider.notifier).deleteProduct(widget.productId!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;

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
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: _pickedFile != null 
                    ? (kIsWeb 
                        ? Image.network(_pickedFile!.path, fit: BoxFit.cover) 
                        : Image.file(File(_pickedFile!.path), fit: BoxFit.cover))
                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                        ? Image.network(_currentImageUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image))
                        : Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primaryLight),
                                const SizedBox(height: 8),
                                Text('Tap to upload image', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
                                ],
                            ),
                            )),
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
                      prefixIcon: Icons.attach_money,
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
                        Text('Category', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textLight)),
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
}
