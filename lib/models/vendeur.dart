class Vendeur {
  final int? id;
  final String nomBoutique;
  final String? slugBoutique;
  final String? description;
  final String telephone;
  final String? email;
  final String? adresse;
  final String? ville;
  final String? province;
  final String? logoBoutique;
  final String? categoriePrincipale;
  final bool? estActif;
  final String? createdAt;

  Vendeur({
    this.id,
    required this.nomBoutique,
    this.slugBoutique,
    this.description,
    required this.telephone,
    this.email,
    this.adresse,
    this.ville,
    this.province,
    this.logoBoutique,
    this.categoriePrincipale,
    this.estActif,
    this.createdAt,
  });

  factory Vendeur.fromJson(Map<String, dynamic> json) {
    return Vendeur(
      id: json['id'],
      nomBoutique: json['nom_boutique'] ?? '',
      slugBoutique: json['slug_boutique'],
      description: json['description'],
      telephone: json['telephone'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      ville: json['ville'],
      province: json['province'],
      logoBoutique: json['logo_boutique'],
      categoriePrincipale: json['categorie_principale'],
      estActif: json['est_actif'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom_boutique': nomBoutique,
      'description': description,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'ville': ville,
      'province': province,
      'categorie_principale': categoriePrincipale,
    };
  }
}
