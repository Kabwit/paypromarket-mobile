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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVendeur = widget.role == 'vendeur';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🎨 Header décoratif avec gradient
              Container(
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isVendeur
                        ? [AppTheme.accentColor, AppTheme.accentColor.withValues(alpha: 0.8)]
                        : [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Icon(
                            isVendeur ? Icons.storefront : Icons.shopping_bag,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isVendeur ? 'PayPro Vendeur' : 'PayPro Client',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 📝 Formulaire
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isVendeur
                            ? 'Gérez votre boutique'
                            : 'Découvrez les produits',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous rapidement avec votre téléphone',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF757575),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ☎️ Téléphone
                      CustomTextField(
                        label: 'Numéro de téléphone',
                        hint: '+243 xxx xxx xxx',
                        controller: _telephoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Le téléphone est requis';
                          return null;
                        },
                      ),

                      // 🔐 Mot de passe
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Mot de passe',
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Le mot de passe est requis';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // ✅ Bouton connexion
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isVendeur
                                ? AppTheme.accentColor
                                : AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 📋 Lien inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous n\'avez pas de compte ? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(
                                    role: widget.role,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isVendeur
                                    ? AppTheme.accentColor
                                    : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
