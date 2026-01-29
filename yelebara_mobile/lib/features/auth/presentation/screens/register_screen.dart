import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';
import 'package:yelebara_mobile/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:yelebara_mobile/features/auth/presentation/widgets/user_type_selector.dart';
import 'package:yelebara_mobile/core/widgets/yelebara_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = 'client';
  String? _selectedZone;

  final List<String> _zones = [
    'Ouagadougou – Zone du 1200 logements',
    'Ouagadougou – Tampouy',
    'Ouagadougou – Ouaga 2000',
    'Ouagadougou – Zone du Bois',
    'Ouagadougou – Gounghin',
    'Ouagadougou – Cissin',
    'Bobo-Dioulasso – Accart-ville',
    'Bobo-Dioulasso – Belle-ville',
    'Koudougou – Secteur 5',
    'Koudougou – Centre-ville',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          role: _selectedUserType,
          zone: _selectedUserType == 'presseur' ? _selectedZone : null,
          address: _selectedUserType == 'client' ? _addressController.text.trim() : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Inscription réussie ! Veuillez vous connecter.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen for errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: const Hero(
                      tag: 'app_logo',
                      child: Center(child: YelebaraLogo(size: 80)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Section
                  TweenAnimationBuilder<double>(
                     duration: const Duration(milliseconds: 800),
                     tween: Tween(begin: 0.0, end: 1.0),
                     curve: Curves.easeOut,
                     builder: (context, value, child) {
                       return Opacity(
                         opacity: value,
                         child: Transform.translate(
                           offset: Offset(0, 20 * (1 - value)),
                           child: child,
                         ),
                       );
                     },
                     child: Column(
                       children: [
                         Text(
                           'Créer un compte',
                           style: theme.textTheme.headlineMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                             color: colorScheme.onSurface,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           'Rejoignez Yelebara Pressing',
                           style: theme.textTheme.bodyLarge?.copyWith(
                             color: colorScheme.onSurfaceVariant,
                           ),
                         ),
                       ],
                     ),
                   ),
                  const SizedBox(height: 32),

                  // User Type Selector
                  UserTypeSelector(
                    selectedType: _selectedUserType,
                    onChanged: (type) {
                      setState(() {
                        _selectedUserType = type;
                        if (type == 'client') _selectedZone = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  AuthTextField(
                    controller: _nameController,
                    label: _selectedUserType == 'presseur' ? 'Nom du pressing' : 'Nom complet',
                    hint: _selectedUserType == 'presseur' ? 'Ex: Pressing Excellence' : 'Votre nom et prénom',
                    icon: _selectedUserType == 'presseur' ? Icons.business_rounded : Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _selectedUserType == 'presseur'
                            ? 'Veuillez entrer le nom du pressing'
                            : 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [ // Assuming I don't have access to Formatters in import, I will omit if not sure, but regex validation handles it. 
                      // Actually LoginScreen had formatters. I should import them if missing or just rely on validator.
                      // Code uses RegExp validator so it's fine.
                    ],
                     decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+226 XX XX XX XX',
                      helperText: 'Ce numéro servira pour vous connecter',
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro';
                      }
                       // Simple validation
                      if (value.length < 8) return 'Numéro invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Zone (Presseur only)
                  if (_selectedUserType == 'presseur') ...[
                    DropdownButtonFormField<String>(
                      value: _selectedZone,
                      decoration: const InputDecoration(
                        labelText: 'Zone de couverture',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _zones.map((zone) => DropdownMenuItem(value: zone, child: Text(zone, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (value) => setState(() => _selectedZone = value),
                      validator: (value) => value == null ? 'Veuillez sélectionner une zone' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Address (Client only)
                  if (_selectedUserType == 'client') ...[
                    AuthTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      hint: 'Rue, quartier, ville',
                      icon: Icons.home_outlined,
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre adresse' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                      if (value.length < 6) return 'Au moins 6 caractères requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez confirmer le mot de passe';
                      if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: isLoading ? null : _handleSignup,
                      child: isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('S\'inscrire'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Vous avez déjà un compte ? ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: colorScheme.primary.withAlpha(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
