import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    // TODO: Connect with actual Riverpod provider for password reset
    await Future.delayed(const Duration(seconds: 1)); // Simulation
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!_codeSent) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code envoyé, veuillez vérifier votre téléphone.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour avec succès.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser mot de passe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _codeSent ? 'Vérifier le code' : 'Identifiez-vous',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent 
                    ? 'Entrez le code reçu et votre nouveau mot de passe.'
                    : 'Entrez votre téléphone ou email pour recevoir un code de vérification.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                AuthTextField(
                  controller: _phoneOrEmailController,
                  label: 'Téléphone ou Email',
                  hint: '70 00 00 00',
                  icon: Icons.person_outline,
                  enabled: !_codeSent,
                  validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est requis' : null,
                ),

                if (_codeSent) ...[
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _codeController,
                    label: 'Code de vérification',
                    hint: '123456',
                    icon: Icons.lock_clock_outlined,
                    validator: (v) => (v == null || v.isEmpty) ? 'Entrez le code' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _newPasswordController,
                    label: 'Nouveau mot de passe',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => (v != null && v.length < 6) ? 'Mot de passe trop court' : null,
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(_codeSent ? 'Changer le mot de passe' : 'Envoyer le code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
