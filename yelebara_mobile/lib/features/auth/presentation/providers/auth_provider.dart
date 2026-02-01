import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/auth/data/models/user_model.dart';
import 'package:yelebara_mobile/features/auth/data/repositories/auth_repository.dart';

import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';

// State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final UserEntity? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    UserEntity? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      user: user ?? this.user,
    );
  }
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      // Valid token found. Try to get current user if possible or just set authenticated
      try {
        final user = await _repository.getCurrentUser();
        state = state.copyWith(isAuthenticated: true, user: user);
      } catch (e) {
        // Token might be invalid or user data missing
        state = state.copyWith(isAuthenticated: true);
      }
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userEntity = await _repository.login(phone, password);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: userEntity,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(); // Reset state
  }

  // Helper moved or removed if not needed since UserEntity has role as String
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
