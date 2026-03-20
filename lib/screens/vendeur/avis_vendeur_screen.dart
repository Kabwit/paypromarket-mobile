import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class AvisVendeurScreen extends StatefulWidget {
  const AvisVendeurScreen({super.key});

  @override
  State<AvisVendeurScreen> createState() => _AvisVendeurScreenState();
}

class _AvisVendeurScreenState extends State<AvisVendeurScreen> {
  bool _isLoading = true;
  List<dynamic> _avis = [];
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadAvis();
  }

  Future<void> _loadAvis({bool loadMore = false}) async {
    if (loadMore) _page++;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('${ApiConfig.mesAvis}?page=$_page&limit=20');
      final list = data['avis'] ?? [];
      setState(() {
        if (loadMore) {
          _avis.addAll(list);
        } else {
          _avis = list;
        }
        _hasMore = (data['pagination']?['page'] ?? 1) < (data['pagination']?['pages'] ?? 1);
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  Future<void> _repondre(int avisId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Répondre à l\'avis'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Votre réponse...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await ApiService.put(ApiConfig.repondreAvis(avisId), {'reponse_vendeur': result});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réponse envoyée'), backgroundColor: AppTheme.successColor),
          );
          _page = 1;
          _loadAvis();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    }
  }

  Widget _buildStars(int note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < note ? Icons.star : Icons.star_border,
        color: AppTheme.accentColor,
        size: 16,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes avis clients')),
      body: _isLoading && _avis.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _avis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 64, color: Color(0xFF2E7D32)),
                      const SizedBox(height: 16),
                      const Text('Aucun avis pour l\'instant', style: TextStyle(color: Color(0xFF757575), fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _page = 1;
                    await _loadAvis();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _avis.length + (_hasMore ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _avis.length) {
                        return Center(
                          child: TextButton(
                            onPressed: () => _loadAvis(loadMore: true),
                            child: const Text('Charger plus'),
                          ),
                        );
                      }
                      final a = _avis[i];
                      final clientName = a['client']?['nom_complet'] ?? 'Client';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    child: Text(
                                      clientName[0].toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(clientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        _buildStars(a['note'] ?? 0),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatDate(a['createdAt']),
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                              if (a['commentaire'] != null) ...[
                                const SizedBox(height: 8),
                                Text(a['commentaire'], style: const TextStyle(fontSize: 14)),
                              ],
                              if (a['reponse_vendeur'] != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F8F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.reply, size: 14, color: AppTheme.primaryColor),
                                          SizedBox(width: 4),
                                          Text('Votre réponse', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.primaryColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(a['reponse_vendeur'], style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _repondre(a['id']),
                                    icon: const Icon(Icons.reply, size: 16),
                                    label: const Text('Répondre', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
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
