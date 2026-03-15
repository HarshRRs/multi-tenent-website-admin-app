import 'package:dio/dio.dart';
// import 'package:event_bite/core/network/api_client.dart';
import 'package:event_bite/features/website_customizer/domain/website_models.dart';

class WebsiteService {
  final Dio _dio;

  WebsiteService(this._dio);

  Future<WebsiteConfig?> fetchConfig() async {
    try {
      final response = await _dio.get('/website');
      if (response.data == null || (response.data as Map).isEmpty) {
        return null;
      }
      return WebsiteConfig.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<WebsiteConfig> updateConfig(WebsiteConfig config) async {
    final response = await _dio.put('/website', data: config.toJson());
    return WebsiteConfig.fromJson(response.data);
  }
}
