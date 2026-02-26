import '../models/produit.dart';

class CartItem {
  final Produit produit;
  int quantite;

  CartItem({required this.produit, this.quantite = 1});

  double get sousTotal => produit.prixAffiche * quantite;
}
