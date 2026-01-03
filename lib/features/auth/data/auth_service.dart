import 'package:dio/dio.dart';
import 'package:rockster/features/auth/domain/auth_models.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: LoginRequest(email: email, password: password).toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register(String email, String password, String name) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return User.fromJson(response.data);
  }
}
