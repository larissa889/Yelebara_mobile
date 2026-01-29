import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/profile/domain/entities/profile_entity.dart';

class ProfileLocalDataSource {
  final SharedPreferences _prefs;

  ProfileLocalDataSource(this._prefs);

  String? _getEmailKey() => _prefs.getString('current_user_email');

  Future<ProfileEntity> getProfile() async {
    final emailKey = _getEmailKey();
    if (emailKey == null) return const ProfileEntity();

    final b64 = _prefs.getString('profile:$emailKey:photo_b64');
    Uint8List? photoBytes;
    if (b64 != null && b64.isNotEmpty) {
      try {
        photoBytes = base64Decode(b64);
      } catch (_) {}
    }

    return ProfileEntity(
      name: _prefs.getString('profile:$emailKey:name'),
      email: _prefs.getString('profile:$emailKey:email'),
      phone: _prefs.getString('profile:$emailKey:phone'),
      phone2: _prefs.getString('profile:$emailKey:phone2'),
      address1: _prefs.getString('profile:$emailKey:address1'),
      address2: _prefs.getString('profile:$emailKey:address2'),
      photoBytes: photoBytes,
    );
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    final emailKey = _getEmailKey();
    if (emailKey == null) return;

    if (profile.name != null) await _prefs.setString('profile:$emailKey:name', profile.name!);
    if (profile.email != null) await _prefs.setString('profile:$emailKey:email', profile.email!);
    if (profile.phone != null) await _prefs.setString('profile:$emailKey:phone', profile.phone!);
    if (profile.phone2 != null) await _prefs.setString('profile:$emailKey:phone2', profile.phone2!);
    if (profile.address1 != null) await _prefs.setString('profile:$emailKey:address1', profile.address1!);
    if (profile.address2 != null) await _prefs.setString('profile:$emailKey:address2', profile.address2!);
  }

  Future<void> updatePhoto(List<int> bytes) async {
    final emailKey = _getEmailKey();
    if (emailKey == null) return;
    
    final b64 = base64Encode(bytes);
    await _prefs.setString('profile:$emailKey:photo_b64', b64);
  }

  Future<void> deletePhoto() async {
    final emailKey = _getEmailKey();
    if (emailKey == null) return;
    await _prefs.remove('profile:$emailKey:photo_b64');
  }

  Future<void> deleteAccount() async {
    final emailKey = _getEmailKey();
    if (emailKey != null) {
      await _prefs.remove('user_role:$emailKey');
      await _prefs.remove('profile:$emailKey:name');
      await _prefs.remove('profile:$emailKey:email');
      await _prefs.remove('profile:$emailKey:phone');
      await _prefs.remove('profile:$emailKey:phone2');
      await _prefs.remove('profile:$emailKey:address1');
      await _prefs.remove('profile:$emailKey:address2');
      await _prefs.remove('profile:$emailKey:photo_b64');
    }
    await _prefs.remove('current_user_email');
  }

  Future<void> logout() async {
    await _prefs.remove('current_user_email');
  }
}
