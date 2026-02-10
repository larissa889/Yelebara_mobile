import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/core/constants/api_constants.dart';
import 'package:yelebara_mobile/core/network/api_client.dart';
import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:yelebara_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(dio);
});

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  Future<UserEntity> login(String phone, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'phone': phone,
        'password': password,
      });
      
      final data = response.data;
      // Assuming response contains 'token' and 'user' object
      // Store token
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
      }
      
      // Convert to UserEntity - assuming user data is in data['user']
      final userData = data['user'];
      return UserEntity(
        id: userData['id']?.toString() ?? '',
        name: userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? '',
        address: userData['address'],
        zone: userData['zone'],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserEntity> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.registerEndpoint, data: {
        'name': name,
        'phone': phone,
        'password': password,
        'role': role,
        if (zone != null) 'zone': zone,
        if (address != null) 'address': address,
      });
      
      final data = response.data;
      // Assuming response contains 'token' and 'user' object
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
      }
      
      // Convert to UserEntity
      final userData = data['user'];
      return UserEntity(
        id: userData['id']?.toString() ?? '',
        name: userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? '',
        address: userData['address'],
        zone: userData['zone'],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // Optional: Call logout endpoint if exists
  }

  Future<UserEntity?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return null;
      
      // TODO: Implement user profile endpoint or decode token
      // For now, return null or a mock user
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserEntity user) async {
    try {
      await _dio.put('${ApiConstants.baseUrl}/users/${user.id}', data: {
        'name': user.name,
        'phone': user.phone,
        'address': user.address,
        'zone': user.zone,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      // Return server error message
      return e.response?.data['message'] ?? 'Erreur inconnue';
    } else {
      return 'Erreur de connexion. Vérifiez votre internet.';
    }
  }
}
