class Produit {
  final int? id;
  final String nom;
  final String? slug;
  final String? description;
  final double prix;
  final double? prixPromo;
  final int stock;
  final int? stockMinimum;
  final String? categorie;
  final String? sousCategorie;
  final List<String> photos;
  final String? lienUnique;
  final String? unite;
  final bool? estActif;
  final String? delaiPreparation;
  final int? vendeurId;
  final Map<String, dynamic>? vendeur;
  final double? noteMoyenne;
  final int? nombreAvis;
  final String? createdAt;

  Produit({
    this.id,
    required this.nom,
    this.slug,
    this.description,
    required this.prix,
    this.prixPromo,
    required this.stock,
    this.stockMinimum,
    this.categorie,
    this.sousCategorie,
    this.photos = const [],
    this.lienUnique,
    this.unite,
    this.estActif,
    this.delaiPreparation,
    this.vendeurId,
    this.vendeur,
    this.noteMoyenne,
    this.nombreAvis,
    this.createdAt,
  });

  static double? _computePromoPrice(Map<String, dynamic> json) {
    // Si prix_promo est directement fourni
    if (json['prix_promo'] != null) return (json['prix_promo']).toDouble();
    // Sinon, calculer à partir de promotion + pourcentage_promotion
    if (json['promotion'] == true && json['pourcentage_promotion'] != null) {
      final prixBase = (json['prix_cdf'] ?? json['prix'] ?? 0).toDouble();
      final pct = (json['pourcentage_promotion'] as num).toDouble();
      if (pct > 0 && pct <= 100) return prixBase * (1 - pct / 100);
    }
    return null;
  }

  factory Produit.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = List<String>.from(json['photos']);
      } else if (json['photos'] is String) {
        photosList = [json['photos']];
      }
    }

    return Produit(
      id: json['id'],
      nom: json['nom'] ?? '',
      slug: json['slug'],
      description: json['description'],
      prix: (json['prix_cdf'] ?? json['prix'] ?? 0).toDouble(),
      prixPromo: _computePromoPrice(json),
      stock: json['stock'] ?? 0,
      stockMinimum: json['stock_minimum'],
      categorie: json['categorie'],
      sousCategorie: json['sous_categorie'],
      photos: photosList,
      lienUnique: json['lien_unique'],
      unite: json['unite'],
      estActif: json['est_actif'] ?? json['disponible'],
      delaiPreparation: json['delai_preparation'],
      vendeurId: json['vendeur_id'],
      vendeur: json['vendeur'] is Map<String, dynamic> ? json['vendeur'] : null,
      noteMoyenne: json['note_moyenne'] != null ? double.tryParse(json['note_moyenne'].toString()) : null,
      nombreAvis: json['nombre_avis'],
      createdAt: json['createdAt'],
    );
  }

  double get prixAffiche => prixPromo ?? prix;

  bool get enPromotion => prixPromo != null && prixPromo! < prix;

  double get pourcentageReduction {
    if (!enPromotion) return 0;
    return ((prix - prixPromo!) / prix * 100);
  }
}
