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
    super.address2,
    super.phone2,
    this.token,
    super.photoUrl,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      zone: json['zone'],
      address: json['address1'] ?? json['address'],
      address2: json['address2'],
      phone2: json['phone2'],
      photoUrl: json['photoUrl'],
      email: json['email'],
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
      'address1': address, // Ensure compatibility with backend
      'address2': address2,
      'phone2': phone2,
      'photoUrl': photoUrl,
      'email': email,
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
      address2: address2,
      phone2: phone2,
      photoUrl: photoUrl,
      email: email,
    );
  }
}
