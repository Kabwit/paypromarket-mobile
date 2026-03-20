import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = true;
  List<dynamic> _verifications = [];
  String _selectedType = 'carte_identite';
  final _numeroController = TextEditingController();
  File? _documentFile;
  File? _selfieFile;
  bool _isSubmitting = false;

  final _typeLabels = {
    'carte_identite': "Carte d'identité",
    'passeport': 'Passeport',
    'permis_conduire': 'Permis de conduire',
    'rccm': 'RCCM',
    'id_nat': 'ID National',
  };

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get(ApiConfig.mesVerifications);
      setState(() {
        final raw = data['verifications'] ?? data;
        _verifications = raw is List ? raw : [];
      });
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage(bool isDocument) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      setState(() {
        if (isDocument) {
          _documentFile = File(picked.path);
        } else {
          _selfieFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_documentFile == null || _selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner le document et le selfie')),
      );
      return;
    }
    if (_numeroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le numéro du document')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.uploadNamedFiles(
        ApiConfig.verifications,
        {
          'document': await _documentFile!.readAsBytes(),
          'selfie': await _selfieFile!.readAsBytes(),
        },
        {
          'document': _documentFile!.path.split(RegExp(r'[/\\]')).last,
          'selfie': _selfieFile!.path.split(RegExp(r'[/\\]')).last,
        },
        fields: {
          'type_document': _selectedType,
          'numero_document': _numeroController.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vérification soumise ! Examen sous 24-48h.'), backgroundColor: AppTheme.successColor),
        );
        _numeroController.clear();
        _documentFile = null;
        _selfieFile = null;
        _loadVerifications();
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

  Color _statutColor(String statut) {
    switch (statut) {
      case 'approuvé':
        return AppTheme.successColor;
      case 'rejeté':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification d\'identité')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Obtenez le badge Vérifié', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Soumettez un document d\'identité pour renforcer la confiance de vos clients.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Historique
                  if (_verifications.isNotEmpty) ...[
                    const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ..._verifications.map((v) => Card(
                      child: ListTile(
                        leading: Icon(Icons.description, color: _statutColor(v['statut'] ?? '')),
                        title: Text(_typeLabels[v['type_document']] ?? v['type_document'] ?? ''),
                        subtitle: Text(v['numero_document'] ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statutColor(v['statut'] ?? '').withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            v['statut'] ?? '',
                            style: TextStyle(color: _statutColor(v['statut'] ?? ''), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],

                  // Formulaire
                  const Text('Nouvelle demande', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type de document'),
                    items: _typeLabels.entries.map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ).toList(),
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro du document',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo document
                  _buildImagePicker(
                    label: 'Photo du document',
                    icon: Icons.badge,
                    file: _documentFile,
                    onTap: () => _pickImage(true),
                  ),
                  const SizedBox(height: 12),

                  // Selfie
                  _buildImagePicker(
                    label: 'Selfie avec le document',
                    icon: Icons.face,
                    file: _selfieFile,
                    onTap: () => _pickImage(false),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send),
                      label: const Text('Soumettre la vérification'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const Text('Appuyez pour choisir', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }
}
