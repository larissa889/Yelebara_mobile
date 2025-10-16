class User {
  final String id;
  final String email;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.role,
  });

  // Méthode pour convertir depuis une map (JSON venant de Laravel)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
