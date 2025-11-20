import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yelebara_mobile/widgets/YelebaraLogo.dart';
import 'package:yelebara_mobile/Screens/RegisterPage.dart';
import 'package:yelebara_mobile/Screens/ForgotPasswordPage.dart';
// Import des pages selon les rôles
import 'package:yelebara_mobile/Client/ClientHomePage.dart';
import 'package:yelebara_mobile/Admin/AdminHomePage.dart';
import 'package:yelebara_mobile/Presseur/PresseurHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Formate le numéro de téléphone au format Burkinabè
  String _formatPhoneNumber(String phone) {
    // Enlever tous les espaces et caractères spéciaux
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si le numéro commence par 226 (code pays Burkina Faso), le retirer
    if (cleaned.startsWith('226')) {
      cleaned = cleaned.substring(3);
    }
    
    // Si le numéro commence par +226, le retirer
    if (phone.startsWith('+226')) {
      cleaned = phone.substring(4).replaceAll(RegExp(r'[^\d]'), '');
    }
    
    return cleaned;
  }

  /// Valide le format du numéro de téléphone
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    
    String cleaned = _formatPhoneNumber(value);
    
    // Au Burkina Faso, les numéros commencent généralement par 5, 6, 7
    // et ont 8 chiffres
    if (cleaned.length != 8) {
      return 'Le numéro doit contenir 8 chiffres';
    }
    
    if (!RegExp(r'^[5-7]').hasMatch(cleaned)) {
      return 'Le numéro doit commencer par 5, 6 ou 7';
    }
    
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Formater le numéro de téléphone
      String formattedPhone = _formatPhoneNumber(_phoneController.text);

      // Simuler une connexion et récupération du rôle
      await Future.delayed(const Duration(seconds: 2));

      // Récupérer le rôle sauvegardé
      String userRole = await _getStoredOrComputedRole(formattedPhone);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Redirection selon le rôle
      _navigateByRole(userRole);
    }
  }

  Future<String> _getStoredOrComputedRole(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final key = phone.trim();
    final stored = prefs.getString('user_role:$key');
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    
    // Fallback: vérifier si c'est un numéro admin ou presseur
    // Vous pouvez définir des numéros spécifiques pour les admins
    if (phone == '70000000' || phone == '76000000') {
      return 'admin';
    }
    
    // Par défaut, tout le monde est client
    return 'client';
  }

  void _navigateByRole(String role) {
    Widget destinationPage;

    switch (role.toLowerCase()) {
      case 'admin':
        destinationPage = const AdminHomePage();
        break;
      case 'presseur':
      case 'beneficiaire':
        destinationPage = const PresseurHomePage();
        break;
      case 'client':
      default:
        destinationPage = const ClientHomePage();
        break;
    }

    // Navigation avec remplacement pour empêcher le retour à la page de connexion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destinationPage),
    );

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion réussie !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Sauvegarder le numéro de l'utilisateur connecté pour le profil
    _saveCurrentUserPhone();
  }

  Future<void> _saveCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _formatPhoneNumber(_phoneController.text);
    if (key.isNotEmpty) {
      await prefs.setString('current_user_phone', key);
      // Pour compatibilité avec le code existant qui utilise 'current_user_email'
      await prefs.setString('current_user_email', key);
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
                  const Center(child: YelebaraLogo(size: 120)),

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
                        // Champ Numéro de téléphone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Numéro de téléphone',
                            hintText: '70 12 34 56',
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: Colors.orange.shade600,
                            ),
                            prefixText: '+226 ',
                            prefixStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
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
                            helperText: 'Format: 70 12 34 56',
                            helperStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          validator: _validatePhoneNumber,
                          onChanged: (value) {
                            // Formater automatiquement avec des espaces
                            if (value.length == 2 || value.length == 5) {
                              if (!value.endsWith(' ')) {
                                _phoneController.text = value + ' ';
                                _phoneController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _phoneController.text.length),
                                );
                              }
                            }
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
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                              );
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
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignupPage()),
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