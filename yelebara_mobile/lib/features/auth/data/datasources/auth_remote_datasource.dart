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
        '/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Vérifier si la réponse contient une erreur logique même avec un code 200
        if (response.data is Map &&
            (response.data['status'] == 'error' ||
                response.data['success'] == false)) {
          throw Exception(response.data['message'] ?? 'Échec de la connexion');
        }
        return UserModel.fromJson(response.data['user'] ?? response.data);
      } else {
        throw Exception('Échec de la connexion: ${response.statusCode}');
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
        '/register',
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'role': role,
          if (zone != null) 'zone': zone,
          if (address != null) 'address1': address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Vérifier si la réponse contient une erreur logique
        if (response.data is Map &&
            (response.data['status'] == 'error' ||
                response.data['success'] == false)) {
          throw Exception(
              response.data['message'] ?? 'Échec de l\'inscription');
        }
        return UserModel.fromJson(response.data['user'] ?? response.data);
      } else {
        throw Exception('Échec de l\'inscription: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data['message'] != null) {
          return Exception(data['message']);
        }
        if (data['error'] != null) {
          return Exception(data['error']);
        }
      }
      // Si le corps de la réponse est une chaîne simple, l'utiliser
      if (data is String && data.isNotEmpty) {
        return Exception(data);
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connexion lente. Veuillez réessayer.');
      case DioExceptionType.connectionError:
        return Exception('Pas de connexion internet.');
      default:
        return Exception('Une erreur est survenue: ${e.message}');
    }
  }
}
