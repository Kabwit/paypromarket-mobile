import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _villeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _categorie;

  final List<String> _categories = [
    'Électronique',
    'Mode & Vêtements',
    'Alimentation',
    'Maison & Déco',
    'Beauté & Santé',
    'Sport & Loisirs',
    'Auto & Moto',
    'Services',
    'Autre',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _villeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success;

    if (widget.role == 'vendeur') {
      success = await auth.inscriptionVendeur(
        nomBoutique: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        motDePasse: _passwordController.text,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ville: _villeController.text.trim().isEmpty
            ? null
            : _villeController.text.trim(),
        categoriePrincipale: _categorie,
      );
    } else {
      success = await auth.inscriptionClient(
        nomComplet: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        motDePasse: _passwordController.text,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ville: _villeController.text.trim().isEmpty
            ? null
            : _villeController.text.trim(),
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
        title: Text(isVendeur ? 'Inscription Vendeur' : 'Inscription Acheteur'),
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
                const SizedBox(height: 16),
                Text(
                  isVendeur ? 'Créer votre boutique' : 'Créer votre compte',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isVendeur
                      ? 'Remplissez les informations de votre boutique'
                      : 'Remplissez vos informations personnelles',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Nom
                CustomTextField(
                  label: isVendeur ? 'Nom de la boutique' : 'Nom complet',
                  hint: isVendeur ? 'Ex: Ma Super Boutique' : 'Ex: Jean Kabwit',
                  controller: _nomController,
                  prefixIcon: isVendeur ? Icons.store : Icons.person,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ce champ est requis';
                    if (v.length < 3) return 'Minimum 3 caractères';
                    return null;
                  },
                ),

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

                // Email (optionnel)
                CustomTextField(
                  label: 'Email (optionnel)',
                  hint: 'votre@email.com',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                // Ville
                CustomTextField(
                  label: 'Ville',
                  hint: 'Ex: Kinshasa',
                  controller: _villeController,
                  prefixIcon: Icons.location_city,
                ),

                // Catégorie (vendeur uniquement)
                if (isVendeur) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _categorie,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie principale',
                        prefixIcon: Icon(Icons.category, color: AppTheme.textSecondary),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _categorie = v),
                    ),
                  ),
                ],

                // Mot de passe
                CustomTextField(
                  label: 'Mot de passe',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le mot de passe est requis';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),

                // Confirmer mot de passe
                CustomTextField(
                  label: 'Confirmer le mot de passe',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Bouton inscription
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: const Text('Créer mon compte'),
                ),

                const SizedBox(height: 24),

                // Lien connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(role: widget.role),
                          ),
                        );
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
