import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String interlocuteurNom;
  final String? interlocuteurType;
  final int? interlocuteurId;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.interlocuteurNom,
    this.interlocuteurType,
    this.interlocuteurId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserType;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadMessages();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserType = prefs.getString('role');
    // Get user ID from stored profile
    final profile = prefs.getString('user_id');
    if (profile != null) {
      _currentUserId = int.tryParse(profile);
    }
    // Fallback: extract from conversation_id
    if (_currentUserId == null && _currentUserType != null) {
      final parts = widget.conversationId.split('_');
      // Format: client_{id}_vendeur_{id}
      if (_currentUserType == 'client' && parts.length >= 2) {
        _currentUserId = int.tryParse(parts[1]);
      } else if (_currentUserType == 'vendeur' && parts.length >= 4) {
        _currentUserId = int.tryParse(parts[3]);
      }
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get(ApiConfig.chatMessages(widget.conversationId));
      final list = data['messages'] ?? [];
      setState(() {
        _messages = List<Map<String, dynamic>>.from(list);
      });
      _scrollToBottom();
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final contenu = _messageController.text.trim();
    if (contenu.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await ApiService.post(ApiConfig.chatEnvoyer, {
        'destinataire_type': widget.interlocuteurType,
        'destinataire_id': widget.interlocuteurId,
        'contenu': contenu,
      });

      // Reload messages
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'envoi: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isSending = false);
  }

  bool _isMyMessage(Map<String, dynamic> msg) {
    return msg['expediteur_type'] == _currentUserType &&
        msg['expediteur_id'] == _currentUserId;
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (diff.inDays == 0) {
      return time;
    } else if (diff.inDays == 1) {
      return 'Hier $time';
    } else if (diff.inDays < 7) {
      const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return '${jours[date.weekday - 1]} $time';
    }
    return '${date.day}/${date.month} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: Text(
                widget.interlocuteurNom.isNotEmpty ? widget.interlocuteurNom[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.interlocuteurNom,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Commencez la conversation !',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMine = _isMyMessage(msg);
                          final isProduit = msg['type_message'] == 'produit';

                          return Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? AppTheme.primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isMine ? Radius.zero : const Radius.circular(16),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isProduit)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.shopping_bag, size: 14,
                                              color: isMine ? Colors.white70 : Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('Produit',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isMine ? Colors.white70 : Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              )),
                                        ],
                                      ),
                                    ),
                                  Text(
                                    msg['contenu'] ?? '',
                                    style: TextStyle(
                                      color: isMine ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(msg['createdAt']),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMine ? Colors.white60 : Colors.grey,
                                        ),
                                      ),
                                      if (isMine) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg['lu'] == true ? Icons.done_all : Icons.done,
                                          size: 14,
                                          color: msg['lu'] == true ? Colors.lightBlueAccent : Colors.white60,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: _isSending
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
