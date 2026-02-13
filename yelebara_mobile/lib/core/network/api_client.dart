import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/core/constants/api_constants.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio();
  final prefs = ref.watch(sharedPreferencesProvider);
  
  dio.options.baseUrl = ApiConstants.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add interceptors (Logging, Token injection, etc.)
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Get token from SharedPreferences
      final jsonString = prefs.getString('CACHED_USER');
      if (jsonString != null) {
        try {
          final jsonMap = jsonDecode(jsonString);
          final token = jsonMap['token'];
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Ignore parsing errors
        }
      }
      return handler.next(options);
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
