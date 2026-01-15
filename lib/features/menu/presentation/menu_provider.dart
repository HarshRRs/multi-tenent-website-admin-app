import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/menu/data/menu_service.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';

enum DataStatus { initial, loading, success, error }

class MenuState {
  final DataStatus status;
  final List<MenuCategory> categories;
  final List<MenuItem> products;
  final String? error;

  MenuState({
    required this.status,
    this.categories = const [],
    this.products = const [],
    this.error,
  });

  MenuState copyWith({
    DataStatus? status,
    List<MenuCategory>? categories,
    List<MenuItem>? products,
    String? error,
  }) {
    return MenuState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      error: error ?? this.error,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuService _menuService;

  MenuNotifier(this._menuService) : super(MenuState(status: DataStatus.initial)) {
    loadMenu();
  }

  Future<void> loadMenu() async {
    state = state.copyWith(status: DataStatus.loading);
    try {
      // Load categories and products in parallel
      final results = await Future.wait([
        _menuService.getCategories(),
        _menuService.getProducts(),
      ]);

      state = state.copyWith(
        status: DataStatus.success,
        categories: results[0] as List<MenuCategory>,
        products: results[1] as List<MenuItem>,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadMenu();
  }
  
  // Optimistic update for availability
  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    final previousProducts = state.products;
    
    // Optimistic update
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          return p.copyWith(isAvailable: isAvailable);
        }
        return p;
      }).toList(),
    );

    try {
      await _menuService.updateProductAvailability(productId, isAvailable);
    } catch (e) {
      // Revert on failure
      state = state.copyWith(
        products: previousProducts,
        error: "Failed to update availability",
      );
    }
  }
  Future<void> addCategory(String name) async {
    try {
      await _menuService.createCategory(name);
      await loadMenu(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: "Failed to add category: $e");
    }
  }

  Future<void> addProduct(MenuItem product) async {
    try {
      await _menuService.createProduct(product);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(error: "Failed to add product: $e");
      rethrow;
    }
  }

  Future<void> updateProduct(MenuItem product) async {
    try {
      await _menuService.updateProduct(product);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(error: "Failed to update product: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _menuService.deleteProduct(id);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(error: "Failed to delete product: $e");
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _menuService.deleteCategory(id);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(error: "Failed to delete category: $e");
      rethrow;
    }
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final menuService = ref.watch(menuServiceProvider);
  return MenuNotifier(menuService);
});
