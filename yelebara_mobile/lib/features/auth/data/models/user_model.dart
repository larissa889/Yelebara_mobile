import 'package:yelebara_mobile/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? token;

  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    super.zone,
    super.address,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      zone: json['zone'],
      address: json['address'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'zone': zone,
      'address': address,
      'token': token,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      phone: phone,
      role: role,
      zone: zone,
      address: address,
    );
  }
}
