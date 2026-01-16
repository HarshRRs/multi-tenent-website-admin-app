import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/network/api_client.dart';
import 'package:rockster/core/utils/secure_storage.dart';
import 'package:rockster/features/auth/data/auth_repository_impl.dart';
import 'package:rockster/features/auth/data/auth_service.dart';
import 'package:rockster/features/auth/domain/auth_models.dart';
import 'package:rockster/features/auth/domain/auth_repository.dart';
import 'package:rockster/core/providers/messenger_provider.dart';

import 'package:rockster/core/providers/providers.dart';

// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: error ?? this.error,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository)
      : super(AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(status: AuthStatus.loading);
    
    try {
      final response = await _authRepository.login(email, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String email, String password, String name, {String businessType = 'restaurant'}) async {
    state = AuthState(status: AuthStatus.loading);
    
    try {
      final response = await _authRepository.register(email, password, name, businessType: businessType);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfile(String name, String address, {bool? isStoreOpen}) async {
    try {
      final updatedUser = await _authRepository.updateProfile(name, address, isStoreOpen: isStoreOpen);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleStoreStatus() async {
    if (state.user == null) return;
    
    final newStatus = !state.user!.isStoreOpen;
    
    // Optimistic update
    final originalUser = state.user!;
    state = state.copyWith(
      user: originalUser.copyWith(isStoreOpen: newStatus),
    );

    try {
      await _authRepository.updateProfile(
        originalUser.name, 
        originalUser.address, 
        isStoreOpen: newStatus,
      );
    } catch (e) {
      // Revert on error
      state = state.copyWith(user: originalUser);
      rethrow;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
