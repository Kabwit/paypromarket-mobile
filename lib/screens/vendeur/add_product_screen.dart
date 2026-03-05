import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../models/produit.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class AddProductScreen extends StatefulWidget {
  final Produit? produit; // null = création, non-null = modification

  const AddProductScreen({super.key, this.produit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _prixPromoController = TextEditingController();
  final _stockController = TextEditingController();
  final _uniteController = TextEditingController();
  final _delaiController = TextEditingController();

  String? _categorie;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Électronique',
    'Mode & Vêtements',
    'Alimentation',
    'Maison & Déco',
    'Beauté & Santé',
    'Sport & Loisirs',
    'Auto & Moto',
    'Services',
    'Autre',
  ];

  bool get isEditing => widget.produit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.produit!;
      _nomController.text = p.nom;
      _descriptionController.text = p.description ?? '';
      _prixController.text = p.prix.toStringAsFixed(0);
      if (p.prixPromo != null) _prixPromoController.text = p.prixPromo!.toStringAsFixed(0);
      _stockController.text = p.stock.toString();
      _uniteController.text = p.unite ?? '';
      _delaiController.text = p.delaiPreparation ?? '';
      _categorie = p.categorie;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _prixPromoController.dispose();
    _stockController.dispose();
    _uniteController.dispose();
    _delaiController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 5);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fields = {
      'nom': _nomController.text.trim(),
      'description': _descriptionController.text.trim(),
      'prix': _prixController.text.trim(),
      'stock': _stockController.text.trim(),
      if (_prixPromoController.text.isNotEmpty)
        'prix_promo': _prixPromoController.text.trim(),
      if (_categorie != null) 'categorie': _categorie!,
      if (_uniteController.text.isNotEmpty) 'unite': _uniteController.text.trim(),
      if (_delaiController.text.isNotEmpty) 'delai_preparation': _delaiController.text.trim(),
    };

    Map<String, dynamic> result;

    if (_selectedImages.isNotEmpty) {
      // Convertir XFile en bytes pour upload compatible web + mobile
      final filesData = <Map<String, dynamic>>[];
      for (final xfile in _selectedImages) {
        final bytes = await xfile.readAsBytes();
        filesData.add({'bytes': bytes, 'filename': xfile.name});
      }
      final url = isEditing
          ? ApiConfig.produitById(widget.produit!.id!)
          : ApiConfig.produits;
      result = await ApiService.uploadMultipleFileBytes(
        url,
        'photos',
        filesData,
        fields: fields,
      );
    } else {
      // Sans images
      final bodyMap = fields.map((k, v) => MapEntry(k, v as dynamic));
      if (isEditing) {
        result = await ApiService.put(ApiConfig.produitById(widget.produit!.id!), bodyMap);
      } else {
        result = await ApiService.post(ApiConfig.produits, bodyMap);
      }
    }

    setState(() => _isLoading = false);

    if (result['success'] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Produit modifié !' : 'Produit créé !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erreur'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le produit' : 'Ajouter un produit'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photos
                const Text('Photos du produit', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.dividerColor, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImages.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.textSecondary),
                              SizedBox(height: 8),
                              Text('Ajouter des photos (max 5)',
                                  style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (ctx, i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<Uint8List>(
                                  future: _selectedImages[i].readAsBytes(),
                                  builder: (ctx, snap) {
                                    if (snap.hasData) {
                                      return Image.memory(
                                        snap.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return const SizedBox(
                                      width: 100, height: 100,
                                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nom
                CustomTextField(
                  label: 'Nom du produit *',
                  controller: _nomController,
                  prefixIcon: Icons.shopping_bag,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le nom est requis';
                    return null;
                  },
                ),

                // Description
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),

                // Catégorie
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _categorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category, color: AppTheme.textSecondary),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categorie = v),
                  ),
                ),

                // Prix
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Prix (FC) *',
                        controller: _prixController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.monetization_on,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requis';
                          if (double.tryParse(v) == null) return 'Nombre invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Prix promo (FC)',
                        controller: _prixPromoController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.local_offer,
                      ),
                    ),
                  ],
                ),

                // Stock
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Stock *',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.inventory,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requis';
                          if (int.tryParse(v) == null) return 'Nombre invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Unité',
                        hint: 'pièce, kg, lot...',
                        controller: _uniteController,
                        prefixIcon: Icons.straighten,
                      ),
                    ),
                  ],
                ),

                // Délai
                CustomTextField(
                  label: 'Délai de préparation',
                  hint: 'Ex: 2 heures, 1 jour...',
                  controller: _delaiController,
                  prefixIcon: Icons.timer,
                ),

                const SizedBox(height: 24),

                // Bouton sauvegarder
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Modifier le produit' : 'Publier le produit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
