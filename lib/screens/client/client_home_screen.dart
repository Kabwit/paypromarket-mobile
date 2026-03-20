import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/produit.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'client_profile_screen.dart';
import '../common/notifications_screen.dart';
import '../common/conversations_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _SearchTab(),
    OrdersScreen(),
    ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: cart.itemCount > 0,
              badgeContent: Text(
                '${cart.itemCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Commandes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              backgroundColor: AppTheme.accentColor,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                '${cart.itemCount} article${cart.itemCount > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}

// ==================== TAB ACCUEIL ====================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Produit> _produits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ApiService.get('${ApiConfig.produitsRecherche}?limit=20');

    if (result['success'] == true) {
      final List data = result['produits'] ?? result['data'] ?? [];
      setState(() {
        _produits = data.map((p) => Produit.fromJson(p)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Erreur de chargement';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.store, size: 24),
            SizedBox(width: 8),
            Text('PayPro Market'),
          ],
        ),
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
        onRefresh: _loadProduits,
        child: _isLoading
            ? const LoadingWidget(message: 'Chargement des produits...')
            : _error != null
                ? EmptyState(
                    icon: Icons.error_outline,
                    title: 'Erreur',
                    subtitle: _error,
                    buttonText: 'Réessayer',
                    onButtonPressed: _loadProduits,
                  )
                : _produits.isEmpty
                    ? const EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Aucun produit',
                        subtitle: 'Les produits apparaîtront ici',
                      )
                    : CustomScrollView(
                        slivers: [
                        // 🎨 Bannière premium d'accueil
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryColor.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '🇨🇩 Bienvenue !',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Découvrez des produits locaux de qualité',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                height: 1.3,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Livraison rapide. Paiement sécurisé.',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // TODO: Ajouter bouton CTA si désiré
                                ],
                              ),
                            ),
                          ),

                          // 📦 Titre + section produits populaires
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Produits populaires',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  Text(
                                    'Voir tout →',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Grille de produits
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.55,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final produit = _produits[index];
                                  return ProductCard(
                                    produit: produit,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ProductDetailScreen(produit: produit),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      context.read<CartProvider>().addToCart(produit);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${produit.nom} ajouté au panier'),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: _produits.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
      ),
    );
  }
}

// ==================== TAB RECHERCHE ====================
class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _searchController = TextEditingController();
  List<Produit> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final result = await ApiService.get(
      '${ApiConfig.produitsRecherche}?q=${Uri.encodeComponent(query)}&limit=30',
    );

    if (result['success'] == true) {
      final List data = result['produits'] ?? result['data'] ?? [];
      setState(() {
        _results = data.map((p) => Produit.fromJson(p)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Rechercher un produit...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
            filled: false,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_searchController.text),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : !_hasSearched
              ? const EmptyState(
                  icon: Icons.search,
                  title: 'Rechercher des produits',
                  subtitle: 'Tapez un mot-clé pour trouver des produits',
                )
              : _results.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'Aucun résultat',
                      subtitle: 'Essayez avec d\'autres mots-clés',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final produit = _results[index];
                        return ProductCard(
                          produit: produit,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(produit: produit),
                              ),
                            );
                          },
                          onAddToCart: () {
                            context.read<CartProvider>().addToCart(produit);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${produit.nom} ajouté au panier'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
