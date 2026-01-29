import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/core/constants/api_constants.dart';
import 'package:yelebara_mobile/core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String phone, String password) async {
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
      
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await _dio.post(ApiConstants.registerEndpoint, data: userData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // Optional: Call logout endpoint if exists
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
