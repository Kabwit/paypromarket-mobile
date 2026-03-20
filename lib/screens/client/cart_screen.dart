import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../widgets/loading_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isOrdering = false;
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _adresseController.dispose();
    _villeController.dispose();
    _telephoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _passerCommande() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();

    if (!auth.isAuthenticated || !auth.isClient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté en tant que client'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_adresseController.text.isEmpty || _telephoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir l\'adresse et le téléphone'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isOrdering = true);

    // Grouper par vendeur et passer une commande par vendeur
    final itemsParVendeur = cart.itemsParVendeur;
    bool allSuccess = true;

    for (var entry in itemsParVendeur.entries) {
      final vendeurId = entry.key;
      final items = entry.value;

      final result = await ApiService.post(ApiConfig.commandes, {
        'vendeur_id': vendeurId,
        'adresse_livraison': _adresseController.text.trim(),
        'ville_livraison': _villeController.text.trim(),
        'telephone_contact': _telephoneController.text.trim(),
        'notes': _notesController.text.trim(),
        'produits': items
            .map((item) => {
                  'produit_id': item.produit.id,
                  'quantite': item.quantite,
                })
            .toList(),
      });

      if (result['success'] != true) {
        allSuccess = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur commande'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }

    setState(() => _isOrdering = false);

    if (allSuccess && mounted) {
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Panier (${cart.itemCount})'),
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier ?'),
                    content: const Text('Tous les articles seront supprimés.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Vider', style: TextStyle(color: AppTheme.errorColor)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isOrdering,
        child: cart.itemCount == 0
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF1B5E20)),
                    SizedBox(height: 16),
                    Text(
                      'Votre panier est vide',
                      style: const TextStyle(fontSize: 18, color: Color(0xFF1B5E20)),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Liste des articles
                    ...cart.itemsList.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Image simulée
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.shopping_bag, color: Color(0xFF1B5E20)),
                                ),
                                const SizedBox(width: 12),
                                // Infos
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.produit.nom,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.produit.prixAffiche.toStringAsFixed(0)} FC',
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantité
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 22),
                                          onPressed: () => cart.decrementQuantite(item.produit.id!),
                                          color: AppTheme.primaryColor,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '${item.quantite}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 22),
                                          onPressed: () => cart.incrementQuantite(item.produit.id!),
                                          color: AppTheme.primaryColor,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.sousTotal.toStringAsFixed(0)} FC',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),

                    // Total
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${cart.totalPrix.toStringAsFixed(0)} FC',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Formulaire livraison
                    const Text(
                      'Informations de livraison',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse de livraison *',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone de contact *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Bouton commander
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isOrdering ? null : _passerCommande,
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: Text('Commander (${cart.totalPrix.toStringAsFixed(0)} FC)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
}
