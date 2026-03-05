import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('${ApiConfig.notifications}?page=$_page&limit=20');
      final list = (data['notifications'] ?? data ?? []) as List;
      final items = list.map((n) => AppNotification.fromJson(n)).toList();
      setState(() {
        if (refresh) {
          _notifications = items;
        } else {
          _notifications.addAll(items);
        }
        _hasMore = items.length >= 20;
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.put(ApiConfig.lireToutNotifications, {});
      setState(() {
        for (var n in _notifications) {
          n = AppNotification(
            id: n.id, titre: n.titre, message: n.message,
            type: n.type, lue: true, createdAt: n.createdAt,
          );
        }
      });
      _loadNotifications(refresh: true);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _markOneRead(AppNotification notif) async {
    if (notif.lue == true) return;
    try {
      await ApiService.put('${ApiConfig.notifications}/${notif.id}/lire', {});
      _loadNotifications(refresh: true);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _deleteNotif(int id) async {
    try {
      await ApiService.delete('${ApiConfig.notifications}/$id');
      setState(() => _notifications.removeWhere((n) => n.id == id));
    } catch (e) {
      // ignore
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'nouvelle_commande':
        return Icons.shopping_cart;
      case 'commande_confirmée':
        return Icons.check_circle;
      case 'commande_expédiée':
        return Icons.local_shipping;
      case 'commande_livrée':
        return Icons.done_all;
      case 'commande_annulée':
        return Icons.cancel;
      case 'paiement_reçu':
        return Icons.payment;
      case 'paiement_échoué':
        return Icons.error;
      case 'rupture_stock':
        return Icons.warning;
      case 'nouveau_message':
        return Icons.message;
      case 'système':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'nouvelle_commande':
        return Colors.blue;
      case 'commande_confirmée':
      case 'commande_livrée':
      case 'paiement_reçu':
        return Colors.green;
      case 'commande_annulée':
      case 'paiement_échoué':
        return Colors.red;
      case 'rupture_stock':
        return Colors.orange;
      case 'nouveau_message':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.lue != true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text('Tout lire', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _isLoading && _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Aucune notification', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _notifications.length) {
                        // Load more
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                _page++;
                                _loadNotifications();
                              },
                              child: const Text('Charger plus'),
                            ),
                          ),
                        );
                      }

                      final notif = _notifications[index];
                      final color = _colorForType(notif.type);

                      return Dismissible(
                        key: Key('notif-${notif.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNotif(notif.id ?? 0),
                        child: Container(
                          color: (notif.lue == true) ? null : color.withValues(alpha: 0.05),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(_iconForType(notif.type), color: color, size: 20),
                            ),
                            title: Text(
                              notif.titre ?? '',
                              style: TextStyle(
                                fontWeight: (notif.lue == true) ? FontWeight.normal : FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif.message ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(_timeAgo(notif.createdAt),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                            trailing: (notif.lue == true)
                                ? null
                                : Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                            onTap: () => _markOneRead(notif),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
