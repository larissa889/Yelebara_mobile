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
  Future<UserModel> updateProfile(UserModel user);
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
        final userData = Map<String, dynamic>.from(response.data['user']);
        userData['token'] = response.data['token'];
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Échec de la connexion: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await dio.post(
        '/user/update',
        data: {
          'name': user.name,
          'email': user.email,
          'address1': user.address, // Note: UserModel has address, API expects address1
          'phone2': user.phone2, // Note: need to check if UserModel has phone2
          // Add other fields if UserModel has them
        },
      );

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
           final userData = Map<String, dynamic>.from(response.data['user']);
        userData['token'] = response.data['token'];
        return UserModel.fromJson(userData);
        }
        throw Exception(response.data['message'] ?? 'Erreur lors de la mise à jour');
      }
      throw Exception('Erreur update: ${response.statusCode}');
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
        final userData = Map<String, dynamic>.from(response.data['user']);
        userData['token'] = response.data['token'];
        return UserModel.fromJson(userData);
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
