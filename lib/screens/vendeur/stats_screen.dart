import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _dashboard = {};
  bool _isLoading = true;
  String _periode = '30j';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.get(ApiConfig.dashboard),
        ApiService.get('${ApiConfig.dashboardStats}?periode=$_periode'),
      ]);
      setState(() {
        _dashboard = results[0];
        _stats = results[1];
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques détaillées'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _periode,
            onSelected: (v) {
              _periode = v;
              _loadData();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: '7j', child: Text('7 derniers jours')),
              PopupMenuItem(value: '30j', child: Text('30 derniers jours')),
              PopupMenuItem(value: '90j', child: Text('3 mois')),
              PopupMenuItem(value: '365j', child: Text('1 an')),
            ],
            icon: const Icon(Icons.date_range),
          ),
        ],
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
                    // KPI Cards row
                    _buildKPICards(),
                    const SizedBox(height: 24),

                    // Revenue chart
                    _buildSectionTitle('Évolution du chiffre d\'affaires', Icons.trending_up),
                    const SizedBox(height: 8),
                    _buildRevenueChart(),
                    const SizedBox(height: 24),

                    // Commandes by status
                    _buildSectionTitle('Répartition des commandes', Icons.pie_chart),
                    const SizedBox(height: 8),
                    _buildOrdersPieChart(),
                    const SizedBox(height: 24),

                    // Top products
                    _buildSectionTitle('Produits populaires', Icons.star),
                    const SizedBox(height: 8),
                    _buildTopProducts(),
                    const SizedBox(height: 24),

                    // Payment modes
                    _buildSectionTitle('Modes de paiement', Icons.payment),
                    const SizedBox(height: 8),
                    _buildPaymentModes(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildKPICards() {
    final ca = _dashboard['ca_mensuel'] ?? _dashboard['ca_total'] ?? 0;
    final commandes = _dashboard['commandes_total'] ?? _dashboard['total_commandes'] ?? 0;
    final produits = _dashboard['produits_total'] ?? _dashboard['total_produits'] ?? 0;
    final vues = _dashboard['vues_total'] ?? _dashboard['total_vues'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _kpiCard('Chiffre d\'affaires', '${_formatNumber(ca)} FC', Icons.monetization_on, Colors.green),
        _kpiCard('Commandes', '$commandes', Icons.shopping_bag, Colors.blue),
        _kpiCard('Produits', '$produits', Icons.inventory, AppTheme.primaryColor),
        _kpiCard('Vues totales', '$vues', Icons.visibility, Colors.orange),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final evolution = _stats['evolution'] ?? _stats['ca_evolution'] ?? [];
    if (evolution is! List || evolution.isEmpty) {
      return _emptyChart('Pas encore de données de revenus');
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < evolution.length; i++) {
      final item = evolution[i];
      final value = (item['total'] ?? item['ca'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(_formatShort(value), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (spots.length / 5).ceilToDouble().clamp(1, 100),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= evolution.length) return const Text('');
                  final label = evolution[idx]['date'] ?? evolution[idx]['jour'] ?? '$idx';
                  return Text(label.toString().length > 5 ? label.toString().substring(5) : label.toString(),
                      style: const TextStyle(fontSize: 9));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 2.5,
              dotData: FlDotData(show: spots.length <= 15),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersPieChart() {
    final statuts = _dashboard['commandes_par_statut'] ?? _stats['commandes_par_statut'];
    if (statuts == null || (statuts is Map && statuts.isEmpty) || (statuts is List && statuts.isEmpty)) {
      return _emptyChart('Pas encore de commandes');
    }

    final data = <String, double>{};
    if (statuts is Map) {
      statuts.forEach((k, v) => data[k.toString()] = (v as num).toDouble());
    } else if (statuts is List) {
      for (var item in statuts) {
        final key = item['statut'] ?? 'autre';
        final val = (item['count'] ?? item['total'] ?? 0).toDouble();
        data[key] = val;
      }
    }

    if (data.isEmpty) return _emptyChart('Pas encore de commandes');

    final colors = [Colors.orange, Colors.blue, Colors.indigo, Colors.purple, Colors.green, Colors.red];
    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final pct = total > 0 ? (e.value / total * 100) : 0;
                  return PieChartSectionData(
                    value: e.value,
                    color: colors[i % colors.length],
                    radius: 40,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, color: colors[i % colors.length]),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_formatStatut(e.key), style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                      Text('${e.value.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final top = _dashboard['produits_populaires'] ?? _stats['top_produits'] ?? [];
    if (top is! List || top.isEmpty) {
      return _emptyChart('Pas encore de produits vendus');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: top.take(5).map<Widget>((p) {
          final nom = p['nom'] ?? p['produit'] ?? 'Produit';
          final ventes = p['ventes'] ?? p['total_vendu'] ?? p['quantite'] ?? 0;
          final vues = p['vues'] ?? 0;
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.shopping_bag, size: 16, color: AppTheme.primaryColor),
            ),
            title: Text(nom.toString(), style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            subtitle: Text('$vues vues', style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$ventes vendus',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentModes() {
    final modes = _stats['paiements_par_mode'] ?? _stats['modes_paiement'] ?? [];
    if (modes == null || (modes is List && modes.isEmpty) || (modes is Map && modes.isEmpty)) {
      return _emptyChart('Pas encore de données de paiement');
    }

    final data = <String, double>{};
    if (modes is Map) {
      modes.forEach((k, v) => data[k.toString()] = (v as num).toDouble());
    } else if (modes is List) {
      for (var item in modes) {
        final key = item['mode_paiement'] ?? item['mode'] ?? 'autre';
        final val = (item['count'] ?? item['total'] ?? 0).toDouble();
        data[key] = val;
      }
    }

    if (data.isEmpty) return _emptyChart('Pas de données');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: data.entries.map((e) {
          final total = data.values.fold(0.0, (a, b) => a + b);
          final pct = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatPaymentMode(e.key), style: const TextStyle(fontSize: 13)),
                    Text('${e.value.toInt()} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    e.key.contains('mobile') ? Colors.green : Colors.blue,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyChart(String message) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey[500])),
    );
  }

  String _formatNumber(dynamic n) {
    if (n == null) return '0';
    final num val = n is num ? n : double.tryParse(n.toString()) ?? 0;
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}K';
    return val.toStringAsFixed(0);
  }

  String _formatShort(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toStringAsFixed(0);
  }

  String _formatStatut(String statut) {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'confirmée': return 'Confirmée';
      case 'préparation': return 'En préparation';
      case 'en_cours': return 'En cours';
      case 'livrée': return 'Livrée';
      case 'annulée': return 'Annulée';
      default: return statut;
    }
  }

  String _formatPaymentMode(String mode) {
    switch (mode) {
      case 'mobile_money': return 'Mobile Money';
      case 'paiement_livraison': return 'Paiement à la livraison';
      default: return mode;
    }
  }
}
