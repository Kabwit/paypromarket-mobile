import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/produit.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../common/chat_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Produit produit;

  const ProductDetailScreen({super.key, required this.produit});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantite = 1;

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(produit.id!);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image en haut
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: produit.photos.isNotEmpty
                  ? PageView.builder(
                      itemCount: produit.photos.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (ctx, i) => CachedNetworkImage(
                        imageUrl: ApiConfig.uploadUrl(produit.photos[i]),
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(Icons.image_not_supported, size: 60),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, size: 80, color: Color(0xFF1B5E20)),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateurs d'images
                  if (produit.photos.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        produit.photos.length,
                        (i) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentImageIndex
                                ? AppTheme.primaryColor
                                : const Color(0xFFC8E6C9),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Catégorie
                  if (produit.categorie != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        produit.categorie!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Nom
                  Text(
                    produit.nom,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prix
                  Row(
                    children: [
                      if (produit.enPromotion) ...[
                        Text(
                          '${produit.prixPromo!.toStringAsFixed(0)} FC',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${produit.prix.toStringAsFixed(0)} FC',
                          style: const TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF81C784),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${produit.pourcentageReduction.toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else
                        Text(
                          '${produit.prix.toStringAsFixed(0)} FC',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock
                  Row(
                    children: [
                      Icon(
                        produit.stock > 0 ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: produit.stock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        produit.stock > 0
                            ? 'En stock (${produit.stock} disponibles)'
                            : 'Rupture de stock',
                        style: TextStyle(
                          color: produit.stock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Vendeur
                  if (produit.vendeur != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                        child: const Icon(Icons.store, color: AppTheme.primaryColor),
                      ),
                      title: Text(produit.vendeur!['nom_boutique'] ?? 'Boutique'),
                      subtitle: Text(produit.vendeur!['ville'] ?? ''),
                    ),
                    const Divider(),
                  ],

                  // Description
                  if (produit.description != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      produit.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Sélecteur de quantité
                  if (produit.stock > 0) ...[
                    const Text(
                      'Quantité',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantite > 1
                              ? () => setState(() => _quantite--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.primaryColor,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantite',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantite < produit.stock
                              ? () => setState(() => _quantite++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 100), // marge pour le bouton flottant
                ],
              ),
            ),
          ),
        ],
      ),

      // Bouton ajouter au panier
      bottomNavigationBar: produit.stock > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            '${(produit.prixAffiche * _quantite).toStringAsFixed(0)} FC',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        cart.addToCart(produit, quantite: _quantite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${produit.nom} ajouté au panier'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart),
                      label: Text(inCart ? 'Déjà dans le panier' : 'Ajouter au panier'),
                    ),
                    if (produit.vendeurId != null) ...[  
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          try {
                            final data = await ApiService.post(ApiConfig.chatDemarrer, {
                              'vendeur_id': produit.vendeurId,
                              'message': 'Bonjour, je suis intéressé(e) par ${produit.nom}',
                              'produit_id': produit.id,
                            });
                            if (context.mounted) {
                              final convId = data['conversation_id'] ?? '';
                              final vendeurNom = produit.vendeur?['nom_boutique'] ?? 'Vendeur';
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  conversationId: convId,
                                  interlocuteurNom: vendeurNom,
                                  interlocuteurType: 'vendeur',
                                  interlocuteurId: produit.vendeurId,
                                ),
                              ));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.chat, color: AppTheme.primaryColor),
                        tooltip: 'Contacter le vendeur',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
