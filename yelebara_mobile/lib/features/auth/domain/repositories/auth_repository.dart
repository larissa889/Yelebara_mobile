import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String phone, String password);
  
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  });

  Future<void> logout();
  
  Future<UserEntity?> getCurrentUser();
  
  Future<void> updateUser(UserEntity user);
}
