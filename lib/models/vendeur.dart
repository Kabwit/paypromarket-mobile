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
  final bool? verifie;
  final String? dateVerification;
  final double? scoreFiabilite;
  final double? noteMoyenne;
  final int? nombreAvis;
  final int? nombreVentes;
  final bool? premium;
  final String? plan;
  final String? dateExpirationPremium;
  final int? limiteProduits;
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
    this.verifie,
    this.dateVerification,
    this.scoreFiabilite,
    this.noteMoyenne,
    this.nombreAvis,
    this.nombreVentes,
    this.premium,
    this.plan,
    this.dateExpirationPremium,
    this.limiteProduits,
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
      verifie: json['verifie'],
      dateVerification: json['date_verification'],
      scoreFiabilite: json['score_fiabilite'] != null ? double.tryParse(json['score_fiabilite'].toString()) : null,
      noteMoyenne: json['note_moyenne'] != null ? double.tryParse(json['note_moyenne'].toString()) : null,
      nombreAvis: json['nombre_avis'],
      nombreVentes: json['nombre_ventes'],
      premium: json['premium'],
      plan: json['plan'],
      dateExpirationPremium: json['date_expiration_premium'],
      limiteProduits: json['limite_produits'],
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
