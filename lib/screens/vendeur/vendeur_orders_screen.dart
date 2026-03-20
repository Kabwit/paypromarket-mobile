import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/commande.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

class VendeurOrdersScreen extends StatefulWidget {
  const VendeurOrdersScreen({super.key});

  @override
  State<VendeurOrdersScreen> createState() => _VendeurOrdersScreenState();
}

class _VendeurOrdersScreenState extends State<VendeurOrdersScreen> {
  List<Commande> _commandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _isLoading = true);

    final result = await ApiService.get(ApiConfig.commandesVendeur);

    if (result['success'] == true) {
      final List data = result['commandes'] ?? result['data'] ?? [];
      setState(() {
        _commandes = data.map((c) => Commande.fromJson(c)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  final Map<String, String> _statutOptions = {
    'confirmee': 'Confirmer',
    'en_preparation': 'En préparation',
    'prete': 'Prête',
    'en_livraison': 'En livraison',
    'livree': 'Livrée',
  };

  Color _statutColor(String? statut) {
    switch (statut) {
      case 'en_attente': return Colors.orange;
      case 'confirmee': return Colors.blue;
      case 'en_preparation': return Colors.purple;
      case 'prete': return Colors.teal;
      case 'en_livraison': return Colors.indigo;
      case 'livree': return AppTheme.successColor;
      case 'annulee': return AppTheme.errorColor;
      default: return const Color(0xFF81C784);
    }
  }

  Future<void> _updateStatut(Commande commande) async {
    final selectedStatut = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Changer le statut'),
        children: _statutOptions.entries.map((e) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, e.key),
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: _statutColor(e.key)),
                const SizedBox(width: 8),
                Text(e.value),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selectedStatut != null) {
      final result = await ApiService.put(
        ApiConfig.statutCommande(commande.id!),
        {'statut': selectedStatut},
      );

      if (result['success'] == true) {
        _loadCommandes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statut mis à jour'), backgroundColor: AppTheme.successColor),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erreur'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commandes (${_commandes.length})'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommandes,
        child: _isLoading
            ? const LoadingWidget()
            : _commandes.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Aucune commande',
                    subtitle: 'Les commandes de vos clients apparaîtront ici',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _commandes.length,
                    itemBuilder: (context, index) {
                      final commande = _commandes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showDetail(commande),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        commande.numeroCommande ?? 'Commande',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statutColor(commande.statut).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        commande.statutLabel,
                                        style: TextStyle(
                                          color: _statutColor(commande.statut),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Client
                                if (commande.client != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        commande.client!['nom_complet'] ?? 'Client',
                                        style: const TextStyle(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 4),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${commande.montantTotal?.toStringAsFixed(0) ?? '0'} FC',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    if (commande.statut != 'livree' && commande.statut != 'annulee')
                                      TextButton.icon(
                                        onPressed: () => _updateStatut(commande),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Statut'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showDetail(Commande commande) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                commande.numeroCommande ?? 'Commande',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _infoRow('Statut', commande.statutLabel),
              _infoRow('Montant', '${commande.montantTotal?.toStringAsFixed(0) ?? '0'} FC'),
              if (commande.client != null)
                _infoRow('Client', commande.client!['nom_complet'] ?? '-'),
              if (commande.telephoneContact != null)
                _infoRow('Téléphone', commande.telephoneContact!),
              if (commande.adresseLivraison != null)
                _infoRow('Adresse', commande.adresseLivraison!),
              if (commande.notes != null && commande.notes!.isNotEmpty)
                _infoRow('Notes', commande.notes!),

              if (commande.lignes != null && commande.lignes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Articles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...commande.lignes!.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(l.produit?['nom'] ?? 'Produit')),
                          Text('x${l.quantite}'),
                          const SizedBox(width: 12),
                          Text('${l.sousTotal?.toStringAsFixed(0) ?? '0'} FC'),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
