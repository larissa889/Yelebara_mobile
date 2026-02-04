import 'package:yelebara_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:yelebara_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:yelebara_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:yelebara_mobile/features/auth/data/models/user_model.dart';

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

  @override
  Future<void> updateUser(UserEntity user) async {
    final userModel = UserModel(
      id: user.id,
      name: user.name,
      phone: user.phone,
      role: user.role,
      zone: user.zone,
      address: user.address,
      photoUrl: user.photoUrl,
      // Preserve token if possible, or leave null if not needed for local updates
    );
    await localDataSource.cacheUser(userModel);
    
    // Sync with remote
    try {
      await remoteDataSource.updateProfile(userModel);
    } catch (e) {
      // If remote fails, we still have local update, but should probably notify user or retry queue
      // For now, silent fail or log is acceptable for MVP as long as local works
       print('Remote update failed: $e');
    }
  }
}
