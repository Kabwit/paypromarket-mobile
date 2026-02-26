class Produit {
  final int? id;
  final String nom;
  final String? slug;
  final String? description;
  final double prix;
  final double? prixPromo;
  final int stock;
  final String? categorie;
  final String? sousCategorie;
  final List<String> photos;
  final String? lienUnique;
  final String? unite;
  final bool? estActif;
  final String? delaiPreparation;
  final int? vendeurId;
  final Map<String, dynamic>? vendeur;
  final String? createdAt;

  Produit({
    this.id,
    required this.nom,
    this.slug,
    this.description,
    required this.prix,
    this.prixPromo,
    required this.stock,
    this.categorie,
    this.sousCategorie,
    this.photos = const [],
    this.lienUnique,
    this.unite,
    this.estActif,
    this.delaiPreparation,
    this.vendeurId,
    this.vendeur,
    this.createdAt,
  });

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
      prix: (json['prix'] ?? 0).toDouble(),
      prixPromo: json['prix_promo'] != null ? (json['prix_promo']).toDouble() : null,
      stock: json['stock'] ?? 0,
      categorie: json['categorie'],
      sousCategorie: json['sous_categorie'],
      photos: photosList,
      lienUnique: json['lien_unique'],
      unite: json['unite'],
      estActif: json['est_actif'],
      delaiPreparation: json['delai_preparation'],
      vendeurId: json['vendeur_id'],
      vendeur: json['vendeur'] is Map<String, dynamic> ? json['vendeur'] : null,
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
