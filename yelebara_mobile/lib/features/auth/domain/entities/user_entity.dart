class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String role; // 'client' | 'presseur'
  final String? zone;
  final String? address;
  final String? address2;
  final String? phone2;
  final String? photoUrl;
  final String? email;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.zone,
    this.address,
    this.address2,
    this.phone2,
    this.photoUrl,
    this.email,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    String? zone,
    String? address,
    String? address2,
    String? phone2,
    String? photoUrl,
    String? email,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      zone: zone ?? this.zone,
      address: address ?? this.address,
      address2: address2 ?? this.address2,
      phone2: phone2 ?? this.phone2,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone;

  @override
  int get hashCode => id.hashCode ^ phone.hashCode;
}
