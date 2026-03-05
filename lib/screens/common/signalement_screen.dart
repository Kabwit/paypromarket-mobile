import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class SignalementScreen extends StatefulWidget {
  final String typeCible; // 'vendeur' ou 'produit'
  final int cibleId;
  final String cibleNom;

  const SignalementScreen({
    super.key,
    required this.typeCible,
    required this.cibleId,
    required this.cibleNom,
  });

  @override
  State<SignalementScreen> createState() => _SignalementScreenState();
}

class _SignalementScreenState extends State<SignalementScreen> {
  String _raison = 'arnaque';
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final _raisonLabels = {
    'produit_contrefait': 'Produit contrefait',
    'arnaque': 'Arnaque',
    'contenu_inapproprie': 'Contenu inapproprié',
    'prix_abusif': 'Prix abusif',
    'non_livraison': 'Non livraison',
    'harcelement': 'Harcèlement',
    'autre': 'Autre',
  };

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Décrivez le problème rencontré')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.post(ApiConfig.signalements, {
        'type_cible': widget.typeCible,
        'cible_id': widget.cibleId,
        'raison': _raison,
        'description': _descriptionController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signalement envoyé. Merci !'), backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signaler un problème')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: AppTheme.errorColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Signalement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.typeCible == 'vendeur' ? 'Vendeur' : 'Produit'}: ${widget.cibleNom}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Raison du signalement', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _raison,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.category)),
              items: _raisonLabels.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)),
              ).toList(),
              onChanged: (v) => setState(() => _raison = v!),
            ),

            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),

            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Décrivez le problème en détail...',
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
                label: const Text('Envoyer le signalement'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
