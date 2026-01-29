class BeneficiaryEntity {
  final String name;
  final String email;
  final String phone;
  final String quartier;

  const BeneficiaryEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.quartier,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
