import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/menu/presentation/menu_provider.dart';
import 'package:rockster/features/menu/presentation/widgets/product_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  // Helper to init controller when data is ready
  void _initTabController(int length) {
    if (_tabController?.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;
    final products = menuState.products;
    final isLoading = menuState.status == DataStatus.loading && categories.isEmpty;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Error and Empty checks omitted for brevity (keep existing)
    if (menuState.status == DataStatus.error) {
       return Scaffold(
        appBar: AppBar(title: const Text('Menu Management')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load menu',
                style: AppTextStyles.headlineMedium,
              ),
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  menuState.error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(menuProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (categories.isEmpty && (menuState.status == DataStatus.success || menuState.status == DataStatus.initial)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu Management')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No categories found'),
              TextButton(
                onPressed: () => ref.read(menuProvider.notifier).refresh(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }


     // Initialize controller now that we have categories
    if (categories.isNotEmpty) {
      _initTabController(categories.length);
    }
    
    // Safety check if controller failed to init
    if (_tabController == null) {
       return const SizedBox.shrink(); 
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            )
          : const Text('Menu Management'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
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
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(menuProvider.notifier).refresh(),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryLight,
          tabs: categories.map((c) => Tab(text: c.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final categoryProducts = products.where((p) => 
            p.categoryId == category.id && 
            (_searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))
          ).toList();

          if (categoryProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No items in this category', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.read(menuProvider.notifier).refresh(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryProducts.length,
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                return ProductCard(
                  product: product,
                  onEdit: () => context.go('/menu/edit/\${product.id}' // Pass product as extra if possible or fetch by ID in edit
                  , extra: product),
                  onAvailabilityChanged: (val) {
                    ref.read(menuProvider.notifier).toggleAvailability(product.id, val);
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/menu/add'),
        backgroundColor: AppColors.primaryLight,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Item', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}

