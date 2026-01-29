import 'package:yelebara_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yelebara_mobile/features/auth/data/models/user_model.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // Mock successful login
    return UserModel(
      id: 'mock_user_123',
      name: 'Test User',
      phone: phone,
      role: 'client', // Default role for testing
    );
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
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'mock_user_new',
      name: name,
      phone: phone,
      role: role,
      zone: zone,
      address: address,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
