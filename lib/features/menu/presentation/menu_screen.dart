import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/components/modern_card.dart';
import 'package:rockster/features/menu/presentation/menu_provider.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';
import 'package:rockster/core/components/shimmer_skeleton.dart';

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
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('New Category', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Category Name',
            labelStyle: theme.textTheme.bodyMedium,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(menuProvider.notifier).addCategory(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.liquidAmber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Add', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCategory(BuildContext context, MenuCategory category) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${category.name}"? This cannot be undone.', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(menuProvider.notifier).deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;
    final isLoading = menuState.status == DataStatus.loading && categories.isEmpty;
    final theme = Theme.of(context);

    if (categories.isNotEmpty) {
      _initTabController(categories.length);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: theme.textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Search collection...',
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      'Menu Collection',
                      style: theme.textTheme.headlineMedium,
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search, color: theme.colorScheme.onSurface),
                onPressed: () => setState(() => _isSearching = !_isSearching),
              ),
              if (!_isSearching) ...[
                IconButton(
                  icon: const Icon(Icons.playlist_add, color: AppColors.liquidAmber),
                  onPressed: () => _showAddCategoryDialog(context),
                ),
              ],
            ],
            bottom: categories.isEmpty
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.liquidAmber,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        indicatorColor: AppColors.liquidAmber,
                        indicatorWeight: 3,
                        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                        labelStyle: theme.textTheme.labelLarge,
                        dividerColor: Colors.transparent,
                        tabs: categories.map((c) => Tab(text: c.name)).toList(),
                      ),
                    ),
                  ),
          ),
        ],
        body: isLoading
            ? _buildSkeletonGrid()
            : categories.isEmpty
                ? _buildEmptyState(theme)
                : TabBarView(
                    controller: _tabController,
                    children: categories.map((category) {
                      final categoryProducts = menuState.products.where((p) =>
                          p.categoryId == category.id &&
                          (_searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))).toList();

                      if (categoryProducts.isEmpty) {
                        return Center(
                          child: Text(
                            'No exquisite items found',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: categoryProducts.length,
                        itemBuilder: (context, index) {
                          final product = categoryProducts[index];
                          return _buildEliteProductCard(product, theme);
                        },
                      );
                    }).toList(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/menu/add'),
        backgroundColor: AppColors.liquidAmber,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildEliteProductCard(MenuItem product, ThemeData theme) {
    return ModernCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/menu/edit/${product.id}', extra: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.etherealBorder,
                          child: const Icon(Icons.restaurant, color: Colors.grey, size: 40),
                        ),
                ),
                // Glass Overlay for availability
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: product.isAvailable,
                        onChanged: (val) => ref.read(menuProvider.notifier).toggleAvailability(product.id, val),
                        activeTrackColor: AppColors.liquidAmber,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '€${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.liquidAmber,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_outlined, size: 80, color: AppColors.etherealBorder),
          const SizedBox(height: 24),
          Text(
            'Curate your first collection',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: () => _showAddCategoryDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.liquidAmber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
