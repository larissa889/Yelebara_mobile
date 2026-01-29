import 'dart:typed_data';

class ProfileEntity {
  final String? name;
  final String? email;
  final String? phone;
  final String? phone2;
  final String? address1;
  final String? address2;
  final Uint8List? photoBytes;

  const ProfileEntity({
    this.name,
    this.email,
    this.phone,
    this.phone2,
    this.address1,
    this.address2,
    this.photoBytes,
  });

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? phone2,
    String? address1,
    String? address2,
    Uint8List? photoBytes,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }
}
