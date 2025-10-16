import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yelebara_mobile/models/User.dart';


class AuthService {
  // 🔗 Ton URL de base Laravel (change si nécessaire)
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // 🟢 Connexion utilisateur
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Vérifie que les données contiennent un utilisateur
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        } else {
          throw Exception('Utilisateur non trouvé dans la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Identifiants incorrects');
      } else {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  // 🔴 Déconnexion (optionnelle)
  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la déconnexion');
      }
    } catch (e) {
      throw Exception('Erreur de déconnexion : $e');
    }
  }
}
