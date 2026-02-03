import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';
import 'package:rockster/features/menu/presentation/menu_provider.dart';
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
  
  // Modifiers state
  final List<ModifierGroupEditState> _modifierGroups = [];
  
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

        // Load modifiers
        _modifierGroups.clear();
        for (var group in product.modifierGroups) {
          _modifierGroups.add(ModifierGroupEditState(
            name: group.name,
            minSelect: group.minSelect,
            maxSelect: group.maxSelect,
            modifiers: group.modifiers
                .map((m) => ModifierEditState(name: m.name, price: m.extraPrice))
                .toList(),
          ));
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

        // 2. Prepare Modifiers
        final List<Map<String, dynamic>> modifierGroupsData = _modifierGroups.map((g) {
          return {
            'name': g.nameController.text,
            'minSelect': int.tryParse(g.minController.text) ?? 0,
            'maxSelect': int.tryParse(g.maxController.text) ?? 1,
            'modifiers': g.modifiers.map((m) => {
              'name': m.nameController.text,
              'extraPrice': double.tryParse(m.priceController.text) ?? 0.0,
            }).toList(),
          };
        }).toList();

        // 3. Create Object (The notifier and service handle the translation to JSON)
        // We need to update MenuProvider/MenuService to handle nested modifier data logic
        // For now, let's assume we pass them as part of the product object if possible or as a separate map.
        
        final product = MenuItem(
            id: widget.productId ?? '', 
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            categoryId: _selectedCategory!,
            imageUrl: mainImageUrl, // Backward compatibility
            images: finalImages,    // Multi-image support
            isAvailable: true,
            modifierGroups: [], // This will be handled in the update call
        );
        
        // Custom update call to include modifiers
        final Map<String, dynamic> productData = {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'categoryId': product.categoryId,
          'imageUrl': product.imageUrl,
          'images': product.images,
          'isAvailable': product.isAvailable,
          'modifierGroups': modifierGroupsData,
        };

        // 4. Call Notifier (Updated)
        if (widget.productId == null) {
            await ref.read(menuProvider.notifier).addProductRaw(productData);
        } else {
            await ref.read(menuProvider.notifier).updateProductRaw(widget.productId!, productData);
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
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
              Text('Images ($currentCount/$maxImages)', style: theme.textTheme.titleMedium),
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
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                                    ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.add_a_photo, color: theme.colorScheme.primary),
                                            const SizedBox(height: 4),
                                            Text('Add', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
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

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g., Truffle Burger',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Ingredients and details...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.euro),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      hint: const Text('Select'),
                      items: categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Modifiers Section
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text('Menu Modifiers', style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18)),
                  subtitle: const Text('Add extras like "Extra Cheese" or "Large Size"', style: TextStyle(fontSize: 12)),
                  children: [
                    ..._modifierGroups.asMap().entries.map((groupEntry) {
                      final groupIndex = groupEntry.key;
                      final group = groupEntry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: group.nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Group Name',
                                      hintText: 'e.g., Size',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _modifierGroups.removeAt(groupIndex)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: group.minController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Min Select',
                                      hintText: '0',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: group.maxController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Max Select',
                                      hintText: '1',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text('Options', style: theme.textTheme.titleSmall),
                            ...group.modifiers.asMap().entries.map((modEntry) {
                              final modIndex = modEntry.key;
                              final mod = modEntry.value;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: mod.nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          hintText: 'Option Name',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: mod.priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          hintText: 'Extra €',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                      onPressed: () => setState(() => group.modifiers.removeAt(modIndex)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            TextButton.icon(
                              onPressed: () => setState(() => group.modifiers.add(ModifierEditState())),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Option'),
                            ),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton(
                        onPressed: () => setState(() => _modifierGroups.add(ModifierGroupEditState())),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Add Modifier Group', style: TextStyle(color: theme.colorScheme.primary)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              if (isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _handleDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
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

class ModifierGroupEditState {
  final TextEditingController nameController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final List<ModifierEditState> modifiers;

  ModifierGroupEditState({
    String name = '',
    int minSelect = 0,
    int maxSelect = 1,
    List<ModifierEditState>? modifiers,
  })  : nameController = TextEditingController(text: name),
        minController = TextEditingController(text: minSelect.toString()),
        maxController = TextEditingController(text: maxSelect.toString()),
        modifiers = modifiers ?? [];
}

class ModifierEditState {
  final TextEditingController nameController;
  final TextEditingController priceController;

  ModifierEditState({
    String name = '',
    double price = 0.0,
  })  : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price.toString());
}
