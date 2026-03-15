import 'package:dio/dio.dart';
import 'package:event_bite/features/auth/domain/auth_models.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';

  AuthService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: LoginRequest(email: email, password: password).toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String businessType = 'restaurant',
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'role': 'manager',
        'businessType': businessType,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    // No-op for service, storage cleared by repo
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data);
  }
  Future<User> updateProfile(String name, String address) async {
    final response = await _dio.put(
      '/auth/profile',
      data: {'name': name, 'address': address},
    );
    return User.fromJson(response.data);
  }
}
