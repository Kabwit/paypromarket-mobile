import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import 'vendeur_products_screen.dart';
import 'vendeur_orders_screen.dart';
import 'vendeur_profile_screen.dart';
import 'avis_vendeur_screen.dart';
import 'verification_screen.dart';
import 'premium_screen.dart';
import 'stats_screen.dart';
import '../common/notifications_screen.dart';
import '../common/conversations_screen.dart';

class VendeurHomeScreen extends StatefulWidget {
  const VendeurHomeScreen({super.key});

  @override
  State<VendeurHomeScreen> createState() => _VendeurHomeScreenState();
}

class _VendeurHomeScreenState extends State<VendeurHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardTab(),
    VendeurProductsScreen(),
    VendeurOrdersScreen(),
    VendeurProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Boutique'),
        ],
      ),
    );
  }
}

// ==================== TAB DASHBOARD ====================
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, dynamic>? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    final result = await ApiService.get(ApiConfig.dashboard);

    if (result['success'] == true) {
      setState(() {
        _dashboard = result;
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
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const ConversationsScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _isLoading
            ? const LoadingWidget(message: 'Chargement du dashboard...')
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte de bienvenue
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '👋 Bienvenue !',
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dashboard?['vendeur']?['nom_boutique'] ?? 'Votre boutique',
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Badges vendeur
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (_dashboard?['vendeur']?['verifie'] == true)
                                _badge(Icons.verified, 'Vérifié', AppTheme.primaryColor)
                              else
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen())),
                                  child: _badge(Icons.error_outline, 'Non vérifié', AppTheme.accentColor),
                                ),
                              if (_dashboard?['vendeur']?['premium'] == true)
                                _badge(Icons.workspace_premium, _dashboard?['vendeur']?['plan'] ?? 'Premium', AppTheme.premiumGold),
                              if (_dashboard?['vendeur']?['score_fiabilite'] != null)
                                _badge(Icons.shield, 'Score: ${double.tryParse(_dashboard!['vendeur']['score_fiabilite'].toString())?.round() ?? 0}%', AppTheme.infoColor),
                              if (_dashboard?['vendeur']?['note_moyenne'] != null)
                                _badge(Icons.star, '${double.tryParse(_dashboard!['vendeur']['note_moyenne'].toString())?.toStringAsFixed(1)}/5', AppTheme.warningColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistiques en grille
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _statCard(
                          'Produits',
                          '${_dashboard?['total_produits'] ?? _dashboard?['totalProduits'] ?? 0}',
                          Icons.inventory,
                          Colors.blue,
                        ),
                        _statCard(
                          'Commandes',
                          '${_dashboard?['total_commandes'] ?? _dashboard?['totalCommandes'] ?? 0}',
                          Icons.receipt_long,
                          Colors.orange,
                        ),
                        _statCard(
                          'Revenus',
                          '${_dashboard?['chiffre_affaires'] ?? _dashboard?['chiffreAffaires'] ?? 0} FC',
                          Icons.monetization_on,
                          AppTheme.successColor,
                        ),
                        _statCard(
                          'En attente',
                          '${_dashboard?['commandes_en_attente'] ?? _dashboard?['commandesEnAttente'] ?? 0}',
                          Icons.hourglass_empty,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions rapides
                    const Text(
                      'Actions rapides',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _actionTile(
                      Icons.add_box,
                      'Ajouter un produit',
                      'Publier un nouveau produit',
                      Colors.blue,
                      () {
                        final homeState = context.findAncestorStateOfType<_VendeurHomeScreenState>();
                        homeState?.setState(() => homeState._currentIndex = 1);
                      },
                    ),
                    _actionTile(
                      Icons.receipt,
                      'Voir les commandes',
                      'Gérer les commandes reçues',
                      Colors.orange,
                      () {
                        final homeState = context.findAncestorStateOfType<_VendeurHomeScreenState>();
                        homeState?.setState(() => homeState._currentIndex = 2);
                      },
                    ),
                    _actionTile(
                      Icons.star,
                      'Avis clients',
                      'Voir et répondre aux avis',
                      AppTheme.warningColor,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvisVendeurScreen())),
                    ),
                    _actionTile(
                      Icons.verified_user,
                      'Vérification',
                      'Soumettre vos documents',
                      AppTheme.primaryColor,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen())),
                    ),
                    _actionTile(
                      Icons.workspace_premium,
                      'Mon Plan',
                      'Gérer votre abonnement',
                      AppTheme.accentColor,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                    ),
                    _actionTile(
                      Icons.bar_chart,
                      'Statistiques',
                      'Graphiques et analyses',
                      Colors.teal,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
