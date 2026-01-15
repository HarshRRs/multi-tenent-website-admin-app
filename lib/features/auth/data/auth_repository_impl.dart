import 'package:rockster/core/utils/secure_storage.dart';
import 'package:rockster/features/auth/data/auth_service.dart';
import 'package:rockster/features/auth/domain/auth_models.dart';
import 'package:rockster/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._authService, this._secureStorage);

  @override
  Future<AuthResponse> login(String email, String password) async {
    final response = await _authService.login(email, password);
    
    // Store tokens
    await _secureStorage.setAccessToken(response.accessToken);
    await _secureStorage.setRefreshToken(response.refreshToken);
    await _secureStorage.setUserId(response.user.id);
    
    return response;
  }

  @override
  Future<AuthResponse> register(String email, String password, String name, {String businessType = 'restaurant'}) async {
    final response = await _authService.register(
      email: email, 
      password: password, 
      name: name,
      businessType: businessType
    );
    
    // Store tokens
    await _secureStorage.setAccessToken(response.accessToken);
    await _secureStorage.setRefreshToken(response.refreshToken);
    await _secureStorage.setUserId(response.user.id);
    
    return response;
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
    await _secureStorage.clearTokens();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!await isAuthenticated()) {
      return null;
    }
    
    try {
      return await _authService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> updateProfile(String name, String address) async {
    return await _authService.updateProfile(name, address);
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isAuthenticated();
  }
}
