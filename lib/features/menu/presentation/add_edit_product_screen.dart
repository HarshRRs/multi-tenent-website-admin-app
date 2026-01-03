import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/components/custom_button.dart';
import 'package:rockster/core/components/custom_text_field.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  // Mock Categories
  final List<MenuCategory> _categories = [
    MenuCategory(id: '1', name: 'Burgers'),
    MenuCategory(id: '2', name: 'Pizza'),
    MenuCategory(id: '3', name: 'Pasta'),
    MenuCategory(id: '4', name: 'Drinks'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      // Mock fetching existing data
      _nameController.text = 'Classic Cheeseburger';
      _descriptionController.text = 'Beef patty, cheese, lettuce';
      _priceController.text = '12.50';
      _selectedCategory = '1';
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
      // Simulate API Save
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.productId == null ? 'Product Added!' : 'Product Updated!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

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
              // Image Picker Placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primaryLight),
                      const SizedBox(height: 8),
                      Text('Tap to upload image', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
                    ],
                  ),
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
                              items: _categories.map((c) => DropdownMenuItem(
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
                  onPressed: () {
                    // Confirm delete dialog logic here
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
