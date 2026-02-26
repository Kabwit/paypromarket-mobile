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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: notifications
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
                          // Bannière
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🇨🇩 PayPro Market RDC',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Achetez local, soutenez nos vendeurs !',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Titre section
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Produits récents',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
