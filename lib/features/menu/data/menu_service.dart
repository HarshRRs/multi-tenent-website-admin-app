import 'package:dio/dio.dart';
import 'package:rockster/features/menu/data/menu_dto.dart';
import 'package:rockster/features/menu/domain/menu_models.dart';

class MenuService {
  final Dio _dio;

  MenuService(this._dio);

  // Categories
  Future<List<MenuCategory>> getCategories() async {
    final response = await _dio.get('/menu/categories');
    return categoriesFromJson(response.data);
  }

  // Products
  Future<List<MenuItem>> getProducts({String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }

    final response = await _dio.get('/menu/products', queryParameters: queryParams);
    return menuItemsFromJson(response.data);
  }

  Future<MenuItem> getProductById(String id) async {
    final response = await _dio.get('/menu/products/$id');
    return menuItemFromJson(response.data);
  }

  Future<MenuItem> createProduct(MenuItem product) async {
    final response = await _dio.post(
      '/menu/products',
      data: menuItemToJson(product),
    );
    return menuItemFromJson(response.data);
  }

  Future<MenuItem> updateProduct(MenuItem product) async {
    final response = await _dio.put(
      '/menu/products/${product.id}',
      data: menuItemToJson(product),
    );
    return menuItemFromJson(response.data);
  }

  // Availability toggle specific endpoint if exists, else use update
  Future<MenuItem> updateProductAvailability(String id, bool isAvailable) async {
    final response = await _dio.patch(
      '/menu/products/$id/availability',
      data: {'isAvailable': isAvailable},
    );
    return menuItemFromJson(response.data);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('/menu/products/$id');
  }
}
