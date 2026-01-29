import 'package:yelebara_mobile/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:yelebara_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:yelebara_mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<ProfileEntity> getProfile() async {
    return _dataSource.getProfile();
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    return _dataSource.updateProfile(profile);
  }

  @override
  Future<void> updatePhoto(List<int> bytes) async {
    return _dataSource.updatePhoto(bytes);
  }

  @override
  Future<void> deletePhoto() async {
    return _dataSource.deletePhoto();
  }

  @override
  Future<void> deleteAccount() async {
    return _dataSource.deleteAccount();
  }

  @override
  Future<void> logout() async {
    return _dataSource.logout();
  }
}
