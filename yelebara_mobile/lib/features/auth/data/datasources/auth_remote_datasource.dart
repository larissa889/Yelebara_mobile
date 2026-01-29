import 'package:dio/dio.dart';
import 'package:yelebara_mobile/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String phone, String password);
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await dio.post(
        '/api/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] ?? response.data);
      } else {
        throw Exception('Échec de la connexion');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  }) async {
    try {
      final response = await dio.post(
        '/api/register',
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'role': role,
          if (zone != null) 'zone': zone,
          if (address != null) 'address': address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data['user'] ?? response.data);
      } else {
        throw Exception('Échec de l\'inscription');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/api/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connexion lente. Veuillez réessayer.');
      case DioExceptionType.connectionError:
        return Exception('Pas de connexion internet.');
      default:
        return Exception('Une erreur est survenue.');
    }
  }
}
