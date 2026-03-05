import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import 'chat_detail_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get(ApiConfig.chatConversations);
      final list = data['conversations'] ?? [];
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(list);
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  String _getInterlocuteurNom(Map<String, dynamic> conv) {
    final inter = conv['interlocuteur'];
    if (inter == null) return 'Utilisateur inconnu';
    final type = conv['interlocuteur_type'];
    if (type == 'vendeur') {
      return inter['nom_boutique'] ?? 'Vendeur';
    } else {
      final nom = inter['nom'] ?? '';
      final prenom = inter['prenom'] ?? '';
      return '$nom $prenom'.trim().isEmpty ? 'Client' : '$nom $prenom'.trim();
    }
  }

  String _getInitiales(String nom) {
    final parts = nom.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom.isNotEmpty ? nom[0].toUpperCase() : '?';
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _conversations.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Aucune conversation', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text('Contactez un vendeur depuis la page d\'un produit',
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: _conversations.length,
                    separatorBuilder: (_, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final nom = _getInterlocuteurNom(conv);
                      final dernierMsg = conv['dernier_message'];
                      final nonLus = conv['non_lus'] ?? 0;
                      final isVendeur = conv['interlocuteur_type'] == 'vendeur';
                      final interlocuteur = conv['interlocuteur'];
                      final logo = isVendeur && interlocuteur != null ? interlocuteur['logo'] : null;
                      final verifie = isVendeur && interlocuteur != null ? (interlocuteur['verifie'] ?? false) : false;

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                          backgroundImage: logo != null
                              ? NetworkImage(ApiConfig.uploadUrl(logo))
                              : null,
                          child: logo == null
                              ? Text(_getInitiales(nom),
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ))
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nom,
                                style: TextStyle(
                                  fontWeight: nonLus > 0 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (verifie)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified, size: 14, color: AppTheme.primaryColor),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          dernierMsg?['contenu'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: nonLus > 0 ? FontWeight.w500 : FontWeight.normal,
                            color: nonLus > 0 ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _timeAgo(dernierMsg?['createdAt']),
                              style: TextStyle(fontSize: 11, color: nonLus > 0 ? AppTheme.primaryColor : Colors.grey),
                            ),
                            if (nonLus > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$nonLus', style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ],
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                conversationId: conv['conversation_id'],
                                interlocuteurNom: nom,
                                interlocuteurType: conv['interlocuteur_type'],
                                interlocuteurId: conv['interlocuteur']?['id'],
                              ),
                            ),
                          );
                          _loadConversations(); // Refresh on return
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
