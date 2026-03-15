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

  Future<MenuCategory> createCategory(String name) async {
    final response = await _dio.post(
      '/menu/categories',
      data: {'name': name},
    );
    // Determine response type: list or single object
    // Our backend returns the created object
    final data = response.data;
    return MenuCategory(id: data['id'], name: data['name']);
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

  Future<void> deleteCategory(String id) async {
    await _dio.delete('/menu/categories/$id');
  }

  Future<String> uploadImage(dynamic file) async {
    // Handling XFile from image_picker
    String fileName = 'upload.jpg';
    List<int> bytes;
    
    if (file.runtimeType.toString().contains('XFile')) {
        bytes = await file.readAsBytes();
        fileName = file.name;
    } else {
        throw Exception('Unsupported file type');
    }

    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _dio.post('/upload', data: formData);
    return response.data['url'];
  }
}
