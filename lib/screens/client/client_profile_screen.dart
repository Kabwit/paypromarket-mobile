import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../common/language_screen.dart';
import '../common/about_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    setState(() => _isLoading = true);
    final result = await ApiService.get(ApiConfig.clientProfil);
    if (result['success'] == true) {
      setState(() {
        _profil = result['client'] ?? result;
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
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false,
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
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profil?['nom_complet'] ?? 'Client',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _profil?['telephone'] ?? '',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Infos
                    _profilCard([
                      _profilItem(Icons.phone, 'Téléphone', _profil?['telephone'] ?? '-'),
                      _profilItem(Icons.email, 'Email', _profil?['email'] ?? 'Non renseigné'),
                      _profilItem(Icons.location_city, 'Ville', _profil?['ville'] ?? 'Non renseignée'),
                      _profilItem(Icons.location_on, 'Adresse', _profil?['adresse'] ?? 'Non renseignée'),
                    ]),
                    const SizedBox(height: 16),

                    // Actions
                    _profilCard([
                      ListTile(
                        leading: const Icon(Icons.history, color: AppTheme.primaryColor),
                        title: const Text('Historique des achats'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock, color: AppTheme.primaryColor),
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO
                        },
                      ),
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
                    ]),
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
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<AuthProvider>().logout();
                                  },
                                  child: const Text('Déconnexion',
                                      style: TextStyle(color: AppTheme.errorColor)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                        label: const Text('Se déconnecter',
                            style: TextStyle(color: AppTheme.errorColor)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _profilCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _profilItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
