class Avis {
  final int? id;
  final int? commandeId;
  final int? produitId;
  final int? clientId;
  final int? vendeurId;
  final int note;
  final String? commentaire;
  final String? reponseVendeur;
  final String? dateReponse;
  final Map<String, dynamic>? client;
  final String? createdAt;

  Avis({
    this.id,
    this.commandeId,
    this.produitId,
    this.clientId,
    this.vendeurId,
    required this.note,
    this.commentaire,
    this.reponseVendeur,
    this.dateReponse,
    this.client,
    this.createdAt,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'],
      commandeId: json['commande_id'],
      produitId: json['produit_id'],
      clientId: json['client_id'],
      vendeurId: json['vendeur_id'],
      note: json['note'] ?? 0,
      commentaire: json['commentaire'],
      reponseVendeur: json['reponse_vendeur'],
      dateReponse: json['date_reponse'],
      client: json['client'] is Map<String, dynamic> ? json['client'] : null,
      createdAt: json['createdAt'],
    );
  }
}
