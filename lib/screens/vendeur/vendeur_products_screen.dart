import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/produit.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'add_product_screen.dart';

class VendeurProductsScreen extends StatefulWidget {
  const VendeurProductsScreen({super.key});

  @override
  State<VendeurProductsScreen> createState() => _VendeurProductsScreenState();
}

class _VendeurProductsScreenState extends State<VendeurProductsScreen> {
  List<Produit> _produits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    setState(() => _isLoading = true);

    final result = await ApiService.get(ApiConfig.produits);

    if (result['success'] == true) {
      final List data = result['produits'] ?? result['data'] ?? [];
      setState(() {
        _produits = data.map((p) => Produit.fromJson(p)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduit(Produit produit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: Text('Voulez-vous supprimer "${produit.nom}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.delete(ApiConfig.produitById(produit.id!));
      if (result['success'] == true) {
        _loadProduits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé'), backgroundColor: AppTheme.successColor),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Produits (${_produits.length})'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProduits,
        child: _isLoading
            ? const LoadingWidget()
            : _produits.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Aucun produit',
                    subtitle: 'Ajoutez votre premier produit',
                    buttonText: 'Ajouter un produit',
                    onButtonPressed: () => _goToAddProduct(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _produits.length,
                    itemBuilder: (context, index) {
                      final produit = _produits[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag, color: Colors.grey),
                          ),
                          title: Text(
                            produit.nom,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${produit.prixAffiche.toStringAsFixed(0)} FC',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    produit.stock > 0 ? Icons.check_circle : Icons.warning,
                                    size: 14,
                                    color: produit.stock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Stock: ${produit.stock}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: produit.stock > 0 ? AppTheme.successColor : AppTheme.errorColor,
                                    ),
                                  ),
                                  if (produit.categorie != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      produit.categorie!,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _goToAddProduct(produit: produit);
                              } else if (value == 'delete') {
                                _deleteProduit(produit);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToAddProduct(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _goToAddProduct({Produit? produit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductScreen(produit: produit)),
    );
    if (result == true) {
      _loadProduits();
    }
  }
}
