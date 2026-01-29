import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/features/auth/data/datasources/mock_auth_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/core/network/api_client.dart';
import 'package:yelebara_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yelebara_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yelebara_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:yelebara_mobile/features/auth/domain/repositories/auth_repository.dart';

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Use Mock for local testing until backend is ready
  return MockAuthRemoteDataSource();
  // final dio = ref.watch(apiClientProvider);
  // return AuthRemoteDataSourceImpl(dio: dio);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(sharedPreferences: prefs);
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(phone, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.register(
        name: name,
        phone: phone,
        password: password,
        role: role,
        zone: zone,
        address: address,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfilePhoto(String? path) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(photoUrl: path);
    // Update local state immediately for UI responsiveness
    state = state.copyWith(user: updatedUser);
    
    // Persist changes
    await _repository.updateUser(updatedUser);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
