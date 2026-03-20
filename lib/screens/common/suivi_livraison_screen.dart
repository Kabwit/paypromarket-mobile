import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class SuiviLivraisonScreen extends StatefulWidget {
  final int commandeId;
  const SuiviLivraisonScreen({super.key, required this.commandeId});

  @override
  State<SuiviLivraisonScreen> createState() => _SuiviLivraisonScreenState();
}

class _SuiviLivraisonScreenState extends State<SuiviLivraisonScreen> {
  Map<String, dynamic>? _commande;
  Map<String, dynamic>? _livraison;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.get(ApiConfig.commandeDetail(widget.commandeId)),
        ApiService.get(ApiConfig.livraisonCommande(widget.commandeId)),
      ]);
      setState(() {
        _commande = results[0];
        _livraison = results[1];
      });
    } catch (e) {
      // Livraison may not exist yet
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi #${widget.commandeId}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    if (_livraison != null) _buildLivraisonDetails(),
                    const SizedBox(height: 16),
                    _buildOrderItems(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderHeader() {
    final statut = _commande?['statut'] ?? _commande?['commande']?['statut'] ?? 'en_attente';
    final total = _commande?['montant_total'] ?? _commande?['commande']?['montant_total'] ?? 0;
    final date = _commande?['date_commande'] ?? _commande?['commande']?['createdAt'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor(statut).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor(statut).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Commande #${widget.commandeId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(statut),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(statut),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total : $total FC', style: const TextStyle(fontSize: 14)),
          if (date.isNotEmpty)
            Text('Date : ${_formatDate(date)}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final statut = _commande?['statut'] ?? _commande?['commande']?['statut'] ?? 'en_attente';

    final steps = [
      {'key': 'en_attente', 'label': 'Commande passée', 'desc': 'Votre commande a été enregistrée', 'icon': Icons.receipt_long},
      {'key': 'confirmée', 'label': 'Confirmée', 'desc': 'Le vendeur a confirmé la commande', 'icon': Icons.check_circle},
      {'key': 'préparation', 'label': 'En préparation', 'desc': 'Le vendeur prépare votre colis', 'icon': Icons.inventory_2},
      {'key': 'expédiée', 'label': 'Expédiée', 'desc': 'En route vers le point de livraison', 'icon': Icons.local_shipping},
      {'key': 'livrée', 'label': 'Livrée', 'desc': 'Commande livrée avec succès', 'icon': Icons.done_all},
    ];

    final statusOrder = ['en_attente', 'confirmée', 'préparation', 'expédiée', 'livrée'];
    final currentIdx = statusOrder.indexOf(statut);
    final isCancelled = statut == 'annulée';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suivi de livraison',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Cette commande a été annulée',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                ],
              ),
            )
          else
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isActive = i <= currentIdx;
              final isCurrent = i == currentIdx;
              final isLast = i == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline line + dot
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppTheme.primaryColor : Colors.grey[300],
                          boxShadow: isCurrent
                              ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 8)]
                              : null,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          size: 16,
                          color: isActive ? Colors.white : const Color(0xFF81C784),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isActive ? AppTheme.primaryColor : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Step info
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['label'] as String,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                              color: isActive ? Colors.black : const Color(0xFF81C784),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['desc'] as String,
                            style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF555555) : const Color(0xFF81C784)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLivraisonDetails() {
    final liv = _livraison?['livraison'] ?? _livraison;
    if (liv == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Détails de livraison',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (liv['adresse_livraison'] != null)
            _detailRow(Icons.location_on, 'Adresse', liv['adresse_livraison']),
          if (liv['ville'] != null)
            _detailRow(Icons.location_city, 'Ville', liv['ville']),
          if (liv['commune'] != null)
            _detailRow(Icons.map, 'Commune', liv['commune']),
          if (liv['frais_livraison'] != null)
            _detailRow(Icons.monetization_on, 'Frais', '${liv['frais_livraison']} FC'),
          if (liv['date_livraison_estimee'] != null)
            _detailRow(Icons.calendar_today, 'Estimée', _formatDate(liv['date_livraison_estimee'])),
          if (liv['livreur'] != null)
            _detailRow(Icons.person, 'Livreur', liv['livreur']),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = _commande?['items'] ?? _commande?['commande']?['items'] ?? [];
    if (items is! List || items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Articles commandés',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...items.map<Widget>((item) {
            final nom = item['nom_produit'] ?? item['produit']?['nom'] ?? 'Produit';
            final qte = item['quantite'] ?? 1;
            final prix = item['prix_unitaire'] ?? item['prix'] ?? 0;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.shopping_bag, size: 16),
              ),
              title: Text(nom.toString(), style: const TextStyle(fontSize: 13)),
              subtitle: Text('Qté: $qte', style: const TextStyle(fontSize: 11)),
              trailing: Text('$prix FC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            );
          }),
        ],
      ),
    );
  }

  Color _statusColor(String statut) {
    switch (statut) {
      case 'en_attente': return Colors.orange;
      case 'confirmée': return Colors.blue;
      case 'préparation': return Colors.indigo;
      case 'expédiée': return Colors.deepPurple;
      case 'livrée': return AppTheme.successColor;
      case 'annulée': return Colors.red;
      default: return const Color(0xFF81C784);
    }
  }

  String _statusLabel(String statut) {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'confirmée': return 'Confirmée';
      case 'préparation': return 'En préparation';
      case 'expédiée': return 'Expédiée';
      case 'livrée': return 'Livrée';
      case 'annulée': return 'Annulée';
      default: return statut;
    }
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }
}
