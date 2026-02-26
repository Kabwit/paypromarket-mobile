import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/produit.dart';

class ProductCard extends StatelessWidget {
  final Produit produit;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.produit,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = produit.photos.isNotEmpty
        ? ApiConfig.uploadUrl(produit.photos.first)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du produit
                    Text(
                      produit.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Prix
                    if (produit.enPromotion) ...[
                      Text(
                        '${produit.prix.toStringAsFixed(0)} FC',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${produit.prixPromo!.toStringAsFixed(0)} FC',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${produit.pourcentageReduction.toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        '${produit.prix.toStringAsFixed(0)} FC',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Bouton ajouter
                    if (onAddToCart != null)
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton.icon(
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          label: const Text('Ajouter', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
