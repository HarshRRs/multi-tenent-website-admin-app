import 'package:dio/dio.dart';
import 'dart:io';
import 'package:rockster/features/website_customizer/domain/website_models.dart';

class WebsiteService {
  final Dio _dio;

  WebsiteService(this._dio);

  Future<WebsiteConfig?> fetchConfig() async {
    try {
      final response = await _dio.get('website');
      if (response.data == null || (response.data as Map).isEmpty) {
        return null;
      }
      return WebsiteConfig.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<WebsiteConfig> updateConfig(WebsiteConfig config) async {
    final response = await _dio.put('website', data: config.toJson());
    return WebsiteConfig.fromJson(response.data);
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _dio.post('upload', data: formData);
    return response.data['url'];
  }

  Future<Map<String, dynamic>> checkSlugAvailability(String slug) async {
    try {
      final response = await _dio.get('/public/check-slug/$slug');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSlug(String slug) async {
    try {
      await _dio.put('/auth/update-slug', data: {'slug': slug});
    } catch (e) {
      rethrow;
    }
  }
}
