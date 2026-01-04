import 'package:dio/dio.dart';
import 'package:rockster/features/auth/domain/auth_models.dart';

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

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveToken(authResponse.accessToken); // Persist token
    return authResponse;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AuthResponse> register(String email, String password, String name, {String? restaurantName}) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (restaurantName != null) 'restaurantName': restaurantName,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    // await _dio.post('/auth/logout'); // Optional API call if backend invalidates tokens
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data);
  }
}
