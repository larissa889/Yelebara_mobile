import 'package:yelebara_mobile/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> updatePhoto(List<int> bytes); // List<int> creates compatibility with Uint8List
  Future<void> deletePhoto();
  Future<void> deleteAccount();
  Future<void> logout();
}
