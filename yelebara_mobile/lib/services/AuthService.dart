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

  // 🟠 Demander la réinitialisation du mot de passe (envoi d'email)
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible d\'envoyer le lien de réinitialisation');
      }
    } catch (e) {
      throw Exception('Erreur demande reset: $e');
    }
  }

  // 🟢 Connexion via Google (échange du token côté backend)
  Future<User?> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/google'),
        headers: {'Accept': 'application/json'},
        body: {
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        } else {
          throw Exception('Utilisateur non trouvé dans la réponse');
        }
      } else {
        throw Exception('Erreur Google (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur connexion Google: $e');
    }
  }

  // 🟢 Connexion via Facebook (échange du token côté backend)
  Future<User?> loginWithFacebook(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/facebook'),
        headers: {'Accept': 'application/json'},
        body: {
          'access_token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        } else {
          throw Exception('Utilisateur non trouvé dans la réponse');
        }
      } else {
        throw Exception('Erreur Facebook (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur connexion Facebook: $e');
    }
  }
}
