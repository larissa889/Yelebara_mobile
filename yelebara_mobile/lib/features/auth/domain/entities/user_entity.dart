class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String role; // 'client' | 'presseur'
  final String? zone;
  final String? address;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.zone,
    this.address,
  });

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
