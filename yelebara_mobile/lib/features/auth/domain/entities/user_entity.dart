class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String role; // 'client' | 'presseur'
  final String? zone;
  final String? address;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.zone,
    this.address,
    this.photoUrl,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    String? zone,
    String? address,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      zone: zone ?? this.zone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
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
