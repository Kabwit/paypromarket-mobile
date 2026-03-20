class Commande {
  final int? id;
  final String? numeroCommande;
  final String? statut;
  final double? montantTotal;
  final double? fraisLivraison;
  final String? adresseLivraison;
  final String? villeLivraison;
  final String? telephoneContact;
  final String? notes;
  final int? clientId;
  final int? vendeurId;
  final List<LigneCommande>? lignes;
  final Map<String, dynamic>? vendeur;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? paiement;
  final Map<String, dynamic>? livraison;
  final String? createdAt;

  Commande({
    this.id,
    this.numeroCommande,
    this.statut,
    this.montantTotal,
    this.fraisLivraison,
    this.adresseLivraison,
    this.villeLivraison,
    this.telephoneContact,
    this.notes,
    this.clientId,
    this.vendeurId,
    this.lignes,
    this.vendeur,
    this.client,
    this.paiement,
    this.livraison,
    this.createdAt,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    List<LigneCommande>? lignesList;
    if (json['lignes'] != null && json['lignes'] is List) {
      lignesList = (json['lignes'] as List)
          .map((l) => LigneCommande.fromJson(l))
          .toList();
    }

    return Commande(
      id: json['id'],
      numeroCommande: json['numero_commande'],
      statut: json['statut'],
      montantTotal: json['montant_total'] != null
          ? (json['montant_total']).toDouble()
          : null,
      fraisLivraison: json['frais_livraison'] != null
          ? (json['frais_livraison']).toDouble()
          : null,
      adresseLivraison: json['adresse_livraison'],
      villeLivraison: json['ville_livraison'],
      telephoneContact: json['telephone_contact'],
      notes: json['notes'],
      clientId: json['client_id'],
      vendeurId: json['vendeur_id'],
      lignes: lignesList,
      vendeur: json['vendeur'] is Map<String, dynamic> ? json['vendeur'] : null,
      client: json['client'] is Map<String, dynamic> ? json['client'] : null,
      paiement: json['paiement'] is Map<String, dynamic> ? json['paiement'] : null,
      livraison: json['livraison'] is Map<String, dynamic> ? json['livraison'] : null,
      createdAt: json['createdAt'],
    );
  }

  String get statutLabel {
    final normalized = statut?.toLowerCase().replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('à', 'a') ?? '';
    
    switch (normalized) {
      case 'en_attente':
        return 'En attente';
      case 'confirmee':
        return 'Confirmée';
      case 'preparation':
        return 'En préparation';
      case 'en_cours':
        return 'En cours';
      case 'pret_pour_livraison':
        return 'Prêt pour livraison';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return statut ?? 'Inconnu';
    }
  }
}

class LigneCommande {
  final int? id;
  final int? produitId;
  final int? quantite;
  final double? prixUnitaire;
  final double? sousTotal;
  final Map<String, dynamic>? produit;

  LigneCommande({
    this.id,
    this.produitId,
    this.quantite,
    this.prixUnitaire,
    this.sousTotal,
    this.produit,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      id: json['id'],
      produitId: json['produit_id'],
      quantite: json['quantite'],
      prixUnitaire: json['prix_unitaire'] != null
          ? (json['prix_unitaire']).toDouble()
          : null,
      sousTotal: json['sous_total'] != null
          ? (json['sous_total']).toDouble()
          : null,
      produit: json['produit'] is Map<String, dynamic> ? json['produit'] : null,
    );
  }
}
