import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class LaisserAvisScreen extends StatefulWidget {
  final int commandeId;
  final int vendeurId;
  final String vendeurNom;

  const LaisserAvisScreen({
    super.key,
    required this.commandeId,
    required this.vendeurId,
    required this.vendeurNom,
  });

  @override
  State<LaisserAvisScreen> createState() => _LaisserAvisScreenState();
}

class _LaisserAvisScreenState extends State<LaisserAvisScreen> {
  int _note = 0;
  final _commentaireController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_note == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une note de 1 à 5 étoiles')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.post(ApiConfig.avis, {
        'commande_id': widget.commandeId,
        'vendeur_id': widget.vendeurId,
        'note': _note,
        'commentaire': _commentaireController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Merci pour votre avis !'), backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laisser un avis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.rate_review, size: 56, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text(
              'Comment était votre expérience avec ${widget.vendeurNom} ?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _note = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _note ? Icons.star : Icons.star_border,
                    color: AppTheme.accentColor,
                    size: 44,
                  ),
                ),
              )),
            ),
            if (_note > 0) ...[
              const SizedBox(height: 8),
              Text(
                ['', 'Très mauvais', 'Mauvais', 'Moyen', 'Bien', 'Excellent'][_note],
                style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 24),

            TextFormField(
              controller: _commentaireController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Votre commentaire (optionnel)...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('Envoyer mon avis'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }
}
