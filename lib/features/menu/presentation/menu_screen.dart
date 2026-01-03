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

  @override
  void initState() {
    super.initState();
    // Logic moved to provider initialization, but we can force refresh if needed
    // ref.read(menuProvider.notifier).refresh(); // optional if provider auto-inits
  }

  @override
  void dispose() {
    _tabController?.dispose();
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

    if (categories.isEmpty && menuState.status == DataStatus.success) {
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
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
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
          final categoryProducts = products.where((p) => p.categoryId == category.id).toList();

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

