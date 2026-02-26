import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/produit.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};
  List<CartItem> get itemsList => _items.values.toList();
  int get itemCount => _items.length;
  int get totalQuantite => _items.values.fold(0, (sum, item) => sum + item.quantite);

  double get totalPrix {
    return _items.values.fold(0.0, (sum, item) => sum + item.sousTotal);
  }

  bool isInCart(int produitId) => _items.containsKey(produitId);

  void addToCart(Produit produit, {int quantite = 1}) {
    if (_items.containsKey(produit.id)) {
      _items[produit.id!]!.quantite += quantite;
    } else {
      _items[produit.id!] = CartItem(produit: produit, quantite: quantite);
    }
    notifyListeners();
  }

  void removeFromCart(int produitId) {
    _items.remove(produitId);
    notifyListeners();
  }

  void updateQuantite(int produitId, int quantite) {
    if (_items.containsKey(produitId)) {
      if (quantite <= 0) {
        _items.remove(produitId);
      } else {
        _items[produitId]!.quantite = quantite;
      }
      notifyListeners();
    }
  }

  void incrementQuantite(int produitId) {
    if (_items.containsKey(produitId)) {
      _items[produitId]!.quantite++;
      notifyListeners();
    }
  }

  void decrementQuantite(int produitId) {
    if (_items.containsKey(produitId)) {
      if (_items[produitId]!.quantite > 1) {
        _items[produitId]!.quantite--;
      } else {
        _items.remove(produitId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Grouper les items par vendeur
  Map<int, List<CartItem>> get itemsParVendeur {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in _items.values) {
      final vendeurId = item.produit.vendeurId ?? 0;
      grouped.putIfAbsent(vendeurId, () => []);
      grouped[vendeurId]!.add(item);
    }
    return grouped;
  }
}
