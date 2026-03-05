import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/commande.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'laisser_avis_screen.dart';
import '../common/signalement_screen.dart';
import '../common/suivi_livraison_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Commande> _commandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    setState(() => _isLoading = true);

    final result = await ApiService.get(ApiConfig.mesCommandes);

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

  Color _statutColor(String? statut) {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'confirmee':
        return Colors.blue;
      case 'en_preparation':
        return Colors.purple;
      case 'prete':
        return Colors.teal;
      case 'en_livraison':
        return Colors.indigo;
      case 'livree':
        return AppTheme.successColor;
      case 'annulee':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _statutIcon(String? statut) {
    switch (statut) {
      case 'en_attente':
        return Icons.hourglass_empty;
      case 'confirmee':
        return Icons.check_circle_outline;
      case 'en_preparation':
        return Icons.kitchen;
      case 'prete':
        return Icons.check_circle;
      case 'en_livraison':
        return Icons.local_shipping;
      case 'livree':
        return Icons.done_all;
      case 'annulee':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommandes,
        child: _isLoading
            ? const LoadingWidget(message: 'Chargement...')
            : _commandes.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Aucune commande',
                    subtitle: 'Vos commandes apparaîtront ici',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _commandes.length,
                    itemBuilder: (context, index) {
                      final commande = _commandes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _statutColor(commande.statut).withValues(alpha: 0.1),
                            child: Icon(
                              _statutIcon(commande.statut),
                              color: _statutColor(commande.statut),
                            ),
                          ),
                          title: Text(
                            commande.numeroCommande ?? 'Commande',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statutColor(commande.statut).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  commande.statutLabel,
                                  style: TextStyle(
                                    color: _statutColor(commande.statut),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${commande.montantTotal?.toStringAsFixed(0) ?? '0'} FC',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: commande.statut == 'en_attente'
                              ? IconButton(
                                  icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                                  onPressed: () => _annulerCommande(commande),
                                )
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _voirDetail(commande),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _annulerCommande(Commande commande) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: Text('Voulez-vous annuler ${commande.numeroCommande} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui, annuler', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.put(ApiConfig.annulerCommande(commande.id!), {});
      if (result['success'] == true) {
        _loadCommandes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande annulée'), backgroundColor: AppTheme.successColor),
          );
        }
      }
    }
  }

  void _voirDetail(Commande commande) {
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                commande.numeroCommande ?? 'Commande',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _infoRow('Statut', commande.statutLabel),
              _infoRow('Montant', '${commande.montantTotal?.toStringAsFixed(0) ?? '0'} FC'),
              if (commande.fraisLivraison != null)
                _infoRow('Frais livraison', '${commande.fraisLivraison!.toStringAsFixed(0)} FC'),
              if (commande.adresseLivraison != null)
                _infoRow('Adresse', commande.adresseLivraison!),
              if (commande.telephoneContact != null)
                _infoRow('Téléphone', commande.telephoneContact!),

              // Bouton suivi de livraison
              if (commande.statut != 'annulee' && commande.statut != 'annulée') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SuiviLivraisonScreen(commandeId: commande.id!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_shipping, size: 18),
                    label: const Text('Suivre la livraison'),
                  ),
                ),
              ],

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
                          const SizedBox(width: 8),
                          Text('${l.sousTotal?.toStringAsFixed(0) ?? '0'} FC'),
                        ],
                      ),
                    )),
              ],

              // Actions pour commande livrée
              if (commande.statut == 'livree' || commande.statut == 'livrée') ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LaisserAvisScreen(
                                commandeId: commande.id!,
                                vendeurId: commande.vendeur?['id'] ?? 0,
                                vendeurNom: commande.vendeur?['nom_boutique'] ?? 'Vendeur',
                              ),
                            ),
                          ).then((result) {
                            if (result == true) _loadCommandes();
                          });
                        },
                        icon: const Icon(Icons.star, size: 18),
                        label: const Text('Avis', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignalementScreen(
                                typeCible: 'vendeur',
                                cibleId: commande.vendeur?['id'] ?? 0,
                                cibleNom: commande.vendeur?['nom_boutique'] ?? 'Vendeur',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.flag, size: 18, color: AppTheme.errorColor),
                        label: const Text('Signaler', style: TextStyle(fontSize: 13, color: AppTheme.errorColor)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorColor)),
                      ),
                    ),
                  ],
                ),
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
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
