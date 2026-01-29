import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';
import 'package:yelebara_mobile/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:yelebara_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:yelebara_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:yelebara_mobile/features/profile/domain/repositories/profile_repository.dart';

// Data Source Provider
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSource(prefs);
});

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileLocalDataSourceProvider));
});

// State
class ProfileState {
  final ProfileEntity profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile = const ProfileEntity(),
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState()) {
    getProfile();
  }

  Future<void> getProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(ProfileEntity newProfile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProfile(newProfile);
      // Refresh to ensure we have the latest (or just merge locally)
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePhoto(List<int> bytes) async {
    try {
      await _repository.updatePhoto(bytes);
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile); 
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePhoto() async {
    try {
      await _repository.deletePhoto();
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAccount();
      state = state.copyWith(isLoading: false);
      // Navigation should be handled by the UI listener
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
