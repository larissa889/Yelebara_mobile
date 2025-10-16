import 'package:flutter/material.dart';
import 'package:yelebara_mobile/screens/Admin/AdminHomePage.dart';
import 'package:yelebara_mobile/screens/BeneficiairePage.dart';
import 'package:yelebara_mobile/screens/Client/ClientHomePage.dart';
import 'package:yelebara_mobile/screens/RegisterPage.dart';

class YelebaraApp extends StatelessWidget {
  const YelebaraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yelebara Pressing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction pour simuler l'authentification et récupérer le rôle
  Future<Map<String, dynamic>> _authenticateUser(String email, String password) async {
    // Simuler un délai d'authentification
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Remplacer par un vrai appel API
    // Simulation basée sur l'email pour démonstration
    if (email.contains('admin')) {
      return {
        'success': true,
        'role': 'admin',
        'userName': 'Administrateur',
        'userId': '1',
      };
    } else if (email.contains('beneficiaire') || email.contains('beneficiary')) {
      return {
        'success': true,
        'role': 'beneficiaire',
        'userName': 'Bénéficiaire',
        'userId': '2',
      };
    } else if (email.contains('client')) {
      return {
        'success': true,
        'role': 'client',
        'userName': 'Client',
        'userId': '3',
      };
    } else {
      // Par défaut, considérer comme client
      return {
        'success': true,
        'role': 'client',
        'userName': 'Utilisateur',
        'userId': '4',
      };
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Authentification
        final authResult = await _authenticateUser(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (authResult['success']) {
          final role = authResult['role'];
          final userName = authResult['userName'];

          // Redirection selon le rôle
          Widget destinationPage;
          
          switch (role) {
            case 'admin':
              destinationPage = AdminHomePage(
                confirmationMessage: 'Bienvenue $userName !',
              );
              break;
            case 'beneficiaire':
              destinationPage = BeneficiaryHomePage(
                confirmationMessage: 'Bienvenue $userName !',
              );
              break;
            case 'client':
              destinationPage = ClientHomePage(
                confirmationMessage: 'Bienvenue $userName !',
              );
              break;
            default:
              destinationPage = ClientHomePage(
                confirmationMessage: 'Bienvenue !',
              );
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        } else {
          // Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou mot de passe incorrect'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),

                  // Logo
                  Center(
                    child: Container(
                      width: isSmallScreen ? 100 : 120,
                      height: isSmallScreen ? 100 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/YELEBARA_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 40),

                  // Titre
                  Text(
                    'Bon retour !',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    'Connectez-vous à votre compte',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 40),

                  // Formulaire
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'votreemail@exemple.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.orange.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.orange.shade600,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigation vers récupération mot de passe
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Bouton de connexion
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 50 : 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Divider avec texte
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // boutons réseaux sociaux
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // connexion avec Google
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: Text(
                            'Google',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // connexion avec Facebook
                          },
                          icon: const Icon(Icons.facebook, size: 24),
                          label: Text(
                            'Facebook',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Lien inscription
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmallScreen ? 14 : 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: Text(
                            'S\'inscrire',
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}