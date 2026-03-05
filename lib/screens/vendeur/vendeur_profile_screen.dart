import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_text_field.dart';
import '../common/language_screen.dart';
import '../common/about_screen.dart';

class VendeurProfileScreen extends StatefulWidget {
  const VendeurProfileScreen({super.key});

  @override
  State<VendeurProfileScreen> createState() => _VendeurProfileScreenState();
}

class _VendeurProfileScreenState extends State<VendeurProfileScreen> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() => _isLoading = true);
    final result = await ApiService.get(ApiConfig.vendeurProfil);
    if (result['success'] == true) {
      setState(() {
        _profil = result['vendeur'] ?? result;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Boutique'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _profil != null ? () => _editProfile() : null,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadProfil,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Logo boutique
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.store, size: 50, color: AppTheme.accentColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profil?['nom_boutique'] ?? 'Ma Boutique',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    if (_profil?['slug_boutique'] != null)
                      Text(
                        '@${_profil!['slug_boutique']}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    const SizedBox(height: 10),
                    // Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_profil?['verifie'] == true)
                          _profileBadge(Icons.verified, 'Vérifié', AppTheme.primaryColor)
                        else
                          _profileBadge(Icons.error_outline, 'Non vérifié', AppTheme.accentColor),
                        if (_profil?['premium'] == true)
                          _profileBadge(Icons.workspace_premium, _profil?['plan'] ?? 'Premium', AppTheme.premiumGold),
                        if (_profil?['note_moyenne'] != null)
                          _profileBadge(Icons.star, '${double.tryParse(_profil!['note_moyenne'].toString())?.toStringAsFixed(1)}/5 (${_profil?['nombre_avis'] ?? 0})', AppTheme.warningColor),
                        if (_profil?['score_fiabilite'] != null)
                          _profileBadge(Icons.shield, 'Score: ${double.tryParse(_profil!['score_fiabilite'].toString())?.round()}%', AppTheme.infoColor),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Informations
                    _card([
                      _item(Icons.phone, 'Téléphone', _profil?['telephone'] ?? '-'),
                      _item(Icons.email, 'Email', _profil?['email'] ?? 'Non renseigné'),
                      _item(Icons.location_city, 'Ville', _profil?['ville'] ?? 'Non renseignée'),
                      _item(Icons.location_on, 'Adresse', _profil?['adresse'] ?? 'Non renseignée'),
                      _item(Icons.category, 'Catégorie', _profil?['categorie_principale'] ?? 'Non renseignée'),
                    ]),
                    const SizedBox(height: 16),

                    if (_profil?['description'] != null && _profil!['description'].toString().isNotEmpty) ...[
                      _card([
                        ListTile(
                          leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                          title: const Text('Description', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          subtitle: Text(_profil!['description']),
                        ),
                      ]),
                      const SizedBox(height: 16),
                    ],

                    // Lien boutique
                    if (_profil?['slug_boutique'] != null)
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.link, color: AppTheme.primaryColor),
                          title: const Text('Lien de votre boutique'),
                          subtitle: Text(
                            '${ApiConfig.baseUrl}/boutique/${_profil!['slug_boutique']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Paramètres
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                            title: const Text('Langue'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                            title: const Text('À propos'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Déconnexion
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Déconnexion'),
                              content: const Text('Voulez-vous vous déconnecter ?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<AuthProvider>().logout();
                                  },
                                  child: const Text('Déconnexion', style: TextStyle(color: AppTheme.errorColor)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                        label: const Text('Se déconnecter', style: TextStyle(color: AppTheme.errorColor)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorColor)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(margin: EdgeInsets.zero, child: Column(children: children));
  }

  Widget _item(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  void _editProfile() {
    final nomController = TextEditingController(text: _profil?['nom_boutique'] ?? '');
    final descController = TextEditingController(text: _profil?['description'] ?? '');
    final adresseController = TextEditingController(text: _profil?['adresse'] ?? '');
    final villeController = TextEditingController(text: _profil?['ville'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Modifier le profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nom de la boutique', controller: nomController),
            CustomTextField(label: 'Description', controller: descController, maxLines: 3),
            CustomTextField(label: 'Adresse', controller: adresseController),
            CustomTextField(label: 'Ville', controller: villeController),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final result = await ApiService.put(ApiConfig.vendeurProfil, {
                  'nom_boutique': nomController.text.trim(),
                  'description': descController.text.trim(),
                  'adresse': adresseController.text.trim(),
                  'ville': villeController.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (result['success'] == true) {
                  _loadProfil();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
