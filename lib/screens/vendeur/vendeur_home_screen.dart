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
                    // 🎨 Header de bienvenue amélioré (Shopify-like)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.accentColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🏪 Votre Boutique',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dashboard?['vendeur']?['nom_boutique'] ?? 'PayPro Market',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (_dashboard?['vendeur']?['verifie'] == true)
                                ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified,
                                            size: 16, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'Vérifié',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ]
                              else
                                ...[
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const VerificationScreen(),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade400,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.warning_amber,
                                              size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            'À vérifier',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              if (_dashboard?['vendeur']?['premium'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.workspace_premium,
                                          size: 16, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        _dashboard?['vendeur']?['plan'] ??
                                            'Premium',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
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

                    // 📊 KPI Cards (Shopify-style)
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _kpiCard(
                          title: 'Revenus',
                          value:
                              '${_dashboard?['chiffre_affaires'] ?? _dashboard?['chiffreAffaires'] ?? 0} FC',
                          icon: Icons.trending_up,
                          color: Colors.green,
                          subtitle: 'Ce mois',
                        ),
                        _kpiCard(
                          title: 'Commandes',
                          value:
                              '${_dashboard?['total_commandes'] ?? _dashboard?['totalCommandes'] ?? 0}',
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                          subtitle: 'Total',
                        ),
                        _kpiCard(
                          title: 'Produits',
                          value:
                              '${_dashboard?['total_produits'] ?? _dashboard?['totalProduits'] ?? 0}',
                          icon: Icons.inventory,
                          color: Colors.orange,
                          subtitle: 'En ligne',
                        ),
                        _kpiCard(
                          title: 'Évaluation',
                          value:
                              '${double.tryParse(_dashboard!['vendeur']['note_moyenne'].toString())?.toStringAsFixed(1) ?? '0'}/5',
                          icon: Icons.star,
                          color: Colors.amber,
                          subtitle:
                              '${_dashboard?['vendeur']?['score_fiabilite'] ?? 0}% fiable',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ⚡ Actions rapides
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Actions rapides',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Boutons d'action en grille
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                      children: [
                        _actionButton(
                          Icons.add_box,
                          'Ajouter\nProduit',
                          Colors.blue,
                          () {
                            final homeState =
                                context.findAncestorStateOfType<
                                    _VendeurHomeScreenState>();
                            homeState?.setState(() => homeState._currentIndex = 1);
                          },
                        ),
                        _actionButton(
                          Icons.receipt_long,
                          'Voir\nCommandes',
                          Colors.orange,
                          () {
                            final homeState =
                                context.findAncestorStateOfType<
                                    _VendeurHomeScreenState>();
                            homeState?.setState(() => homeState._currentIndex = 2);
                          },
                        ),
                        _actionButton(
                          Icons.star,
                          'Avis\nClients',
                          Colors.amber,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AvisVendeurScreen(),
                            ),
                          ),
                        ),
                        _actionButton(
                          Icons.bar_chart,
                          'Stats &\nAnalytics',
                          Colors.teal,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          ),
                        ),
                        _actionButton(
                          Icons.workspace_premium,
                          'Mon\nPlan',
                          Colors.purple,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PremiumScreen(),
                            ),
                          ),
                        ),
                        _actionButton(
                          Icons.person,
                          'Profil &\nBoutique',
                          Colors.pink,
                          () {
                            final homeState =
                                context.findAncestorStateOfType<
                                    _VendeurHomeScreenState>();
                            homeState?.setState(() => homeState._currentIndex = 3);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFBDBDBD),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

}
