import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'client' ou 'vendeur'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success;

    if (widget.role == 'vendeur') {
      success = await auth.connexionVendeur(
        telephone: _telephoneController.text.trim(),
        motDePasse: _passwordController.text,
      );
    } else {
      success = await auth.connexionClient(
        telephone: _telephoneController.text.trim(),
        motDePasse: _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVendeur = widget.role == 'vendeur';

    return Scaffold(
      appBar: AppBar(
        title: Text(isVendeur ? 'Connexion Vendeur' : 'Connexion Acheteur'),
      ),
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Icône
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isVendeur
                      ? AppTheme.accentColor.withValues(alpha: 0.1)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    isVendeur ? Icons.storefront : Icons.shopping_bag,
                    size: 40,
                    color: isVendeur ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isVendeur ? 'Bienvenue, Vendeur !' : 'Bienvenue !',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Téléphone
                CustomTextField(
                  label: 'Numéro de téléphone',
                  hint: '+243 xxx xxx xxx',
                  controller: _telephoneController,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le téléphone est requis';
                    return null;
                  },
                ),

                // Mot de passe
                CustomTextField(
                  label: 'Mot de passe',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Bouton connexion
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: const Text('Se connecter'),
                ),

                const SizedBox(height: 24),

                // Lien inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas de compte ? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(role: widget.role),
                          ),
                        );
                      },
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
