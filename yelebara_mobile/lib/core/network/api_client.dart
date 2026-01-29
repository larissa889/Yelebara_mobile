import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/core/constants/api_constants.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  dio.options.baseUrl = ApiConstants.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 10);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add interceptors (Logging, Token injection, etc.)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
