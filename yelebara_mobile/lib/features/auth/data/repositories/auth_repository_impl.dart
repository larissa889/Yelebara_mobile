import 'package:yelebara_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yelebara_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:yelebara_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String phone, String password) async {
    final user = await remoteDataSource.login(phone, password);
    await localDataSource.cacheUser(user);
    return user.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? zone,
    String? address,
  }) async {
    final user = await remoteDataSource.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
      zone: zone,
      address: address,
    );
    await localDataSource.cacheUser(user);
    return user.toEntity();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await localDataSource.clearCache();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cachedUser = await localDataSource.getCachedUser();
    return cachedUser?.toEntity();
  }
}
