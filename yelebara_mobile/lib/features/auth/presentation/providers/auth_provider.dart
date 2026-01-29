import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/auth/data/models/user_model.dart';
import 'package:yelebara_mobile/features/auth/data/repositories/auth_repository.dart';

// State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final User? user;

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
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error, // If not provided, it clears the error (or use null to clear explicitly)
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
      // Valid token found. In a real app, verify token validity with API.
      // For now, we assume it's valid and maybe load user profile later.
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.login(phone, password);
      
      // Parse User from data (assuming API returns 'user' object)
      // For now, construct a dummy user if not fully provided
      final user = User(
        id: data['user']?['id']?.toString() ?? '0',
        phone: phone,
        role: _mapRole(data['user']?['role']),
        token: data['token'],
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(); // Reset state
  }

  UserRole _mapRole(String? role) {
    if (role == 'admin') return UserRole.admin;
    if (role == 'presseur') return UserRole.presseur;
    return UserRole.client;
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
