import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _planData;
  List<dynamic> _stocksBas = [];
  bool _isProcessing = false;

  final _plans = {
    'gratuit': {'limite': 20, 'prix': 0, 'icon': Icons.storefront, 'color': const Color(0xFF81C784)},
    'premium': {'limite': 100, 'prix': 10, 'icon': Icons.workspace_premium, 'color': AppTheme.accentColor},
    'business': {'limite': 500, 'prix': 25, 'icon': Icons.diamond, 'color': AppTheme.primaryColor},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final plan = await ApiService.get(ApiConfig.monPlan);
      final stocks = await ApiService.get(ApiConfig.stocksBas);
      setState(() {
        _planData = plan;
        _stocksBas = [
          ...stocks['rupture'] ?? [],
          ...stocks['stock_bas'] ?? [],
        ];
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  Future<void> _souscrire(String plan) async {
    if (plan == 'gratuit') return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Passer à $plan ?'),
        content: Text('Abonnement de ${_plans[plan]?['prix']} USD/mois. Confirmer ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer')),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isProcessing = true);
    try {
      await ApiService.post(ApiConfig.souscrirePlan, {'plan': plan});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan $plan activé !'), backgroundColor: AppTheme.successColor),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Plan')),
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
                    // Current plan banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Plan ${(_planData?['plan'] ?? 'gratuit').toString().toUpperCase()}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Produits: ${_planData?['produits_utilises'] ?? 0}/${_planData?['limite_produits'] ?? 20}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          if (_planData?['date_expiration'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Expire le ${_formatDate(_planData!['date_expiration'])}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Plans
                    const Text('Choisir un plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),

                    ..._plans.entries.map((entry) {
                      final name = entry.key;
                      final info = entry.value;
                      final isCurrent = _planData?['plan'] == name;
                      return Card(
                        elevation: isCurrent ? 4 : 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: (info['color'] as Color).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(info['icon'] as IconData, color: info['color'] as Color, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name[0].toUpperCase() + name.substring(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text('Jusqu\'à ${info['limite']} produits', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    (info['prix'] as int) > 0 ? '${info['prix']} USD/mois' : 'Gratuit',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: info['color'] as Color),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Actuel', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 11)),
                                    )
                                  else
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: _isProcessing ? null : () => _souscrire(name),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          textStyle: const TextStyle(fontSize: 12),
                                        ),
                                        child: const Text('Choisir'),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Stocks bas
                    if (_stocksBas.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber, color: AppTheme.accentColor),
                          const SizedBox(width: 8),
                          Text('Alertes stock (${_stocksBas.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._stocksBas.map((p) => Card(
                        child: ListTile(
                          leading: Icon(
                            (p['stock'] ?? 0) == 0 ? Icons.error : Icons.warning,
                            color: (p['stock'] ?? 0) == 0 ? AppTheme.errorColor : AppTheme.accentColor,
                          ),
                          title: Text(p['nom'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Stock: ${p['stock']} / Min: ${p['stock_minimum'] ?? 5}'),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }
}
