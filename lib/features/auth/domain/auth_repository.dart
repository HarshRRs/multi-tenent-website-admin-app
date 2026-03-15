import 'package:event_bite/features/auth/domain/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name, {String businessType = 'restaurant'});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<User> updateProfile(String name, String address); // Added
  Future<bool> isAuthenticated();
}
