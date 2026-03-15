import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_bite/core/theme/app_colors.dart';
import 'package:event_bite/core/components/modern_button.dart';
import 'package:event_bite/core/components/modern_card.dart';
import 'package:event_bite/core/components/glossy_metric_card.dart';
import 'package:event_bite/features/menu/presentation/menu_provider.dart';
import 'package:event_bite/features/menu/presentation/widgets/product_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initTabController(int length) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('New Category', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Category Name',
            labelStyle: GoogleFonts.inter(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondaryLight)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(menuProvider.notifier).addCategory(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.burntTerracotta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
      ),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, MenuCategory category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${category.name}"? This cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondaryLight)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(menuProvider.notifier).deleteCategory(category.id);
    }
  }

  Future<void> _confirmDeleteProduct(BuildContext context, MenuItem product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${product.name}"?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondaryLight)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(menuProvider.notifier).deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;
    final products = menuState.products;
    final isLoading = menuState.status == DataStatus.loading && categories.isEmpty;

    if (categories.isNotEmpty) {
      _initTabController(categories.length);
    }

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.cloudDancer,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: true,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.inter(color: AppColors.deepInk),
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                    ),
                  )
                : Text(
                    'Menu Management',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepInk,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.deepInk),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
              if (!_isSearching) ...[
                if (categories.isNotEmpty && _tabController != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.burntTerracotta),
                    onPressed: () => _confirmDeleteCategory(context, categories[_tabController!.index]),
                  ),
                IconButton(
                  icon: const Icon(Icons.playlist_add, color: AppColors.burntTerracotta),
                  onPressed: () => _showAddCategoryDialog(context),
                ),
              ],
            ],
            bottom: categories.isEmpty
                ? null
                : TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.burntTerracotta,
                    unselectedLabelColor: AppColors.textSecondaryLight,
                    indicatorColor: AppColors.burntTerracotta,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    tabs: categories.map((c) => Tab(text: c.name)).toList(),
                  ),
          ),
        ],
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta))
            : categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu, size: 64, color: AppColors.softBorder),
                        const SizedBox(height: 16),
                        Text(
                          'Start by adding a category',
                          style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 16),
                        ModernButton(
                          text: 'Add Category',
                          icon: Icons.add,
                          onPressed: () => _showAddCategoryDialog(context),
                        ).paddingSymmetric(horizontal: 48),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: categories.map((category) {
                      final categoryProducts = menuState.products.where((p) =>
                          p.categoryId == category.id &&
                          (_searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))).toList();

                      if (categoryProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No items in this category',
                            style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categoryProducts.length,
                        itemBuilder: (context, index) {
                          final product = categoryProducts[index];
                          return ModernCard(
                            padding: EdgeInsets.zero,
                            onTap: () => context.go('/menu/edit/\${product.id}', extra: product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        product.imageUrl != null
                                          ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                                          : Container(
                                              color: AppColors.cloudDancer,
                                              child: const Icon(Icons.fastfood, color: AppColors.burntTerracotta),
                                            ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Switch(
                                            value: product.isAvailable,
                                            onChanged: (val) {
                                              ref.read(menuProvider.notifier).toggleAvailability(product.id, val);
                                            },
                                            activeTrackColor: AppColors.burntTerracotta,
                                          ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: GestureDetector(
                                            onTap: () => _confirmDeleteProduct(context, product),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.deepInk,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'â‚¬\${product.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.burntTerracotta,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/menu/add'),
        backgroundColor: AppColors.burntTerracotta,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Item', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

extension PaddingExtension on Widget {
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
