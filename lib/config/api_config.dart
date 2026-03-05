class ApiConfig {
  // Changez cette IP par celle de votre machine (ipconfig)
  // Pour web/iPhone sur le même Wi-Fi, utiliser l'IP locale
  // Pour Android Emulator, utiliser 10.0.2.2
  // Changez avec votre IP locale (ipconfig) ou 10.0.2.2 pour émulateur Android
  static const String baseUrl = 'http://10.242.164.149:5000';
  static const String apiUrl = '$baseUrl/api';

  // Auth
  static const String vendeurInscription = '$apiUrl/auth/vendeur/inscription';
  static const String vendeurConnexion = '$apiUrl/auth/vendeur/connexion';
  static const String clientInscription = '$apiUrl/auth/client/inscription';
  static const String clientConnexion = '$apiUrl/auth/client/connexion';
  static const String profil = '$apiUrl/auth/profil';

  // Vendeurs
  static const String boutiques = '$apiUrl/vendeurs/boutiques';
  static String boutiqueBySlug(String slug) => '$apiUrl/vendeurs/boutique/$slug';
  static const String vendeurProfil = '$apiUrl/vendeurs/profil';
  static const String vendeurLogo = '$apiUrl/vendeurs/logo';
  static const String zonesLivraison = '$apiUrl/vendeurs/zones-livraison';
  static String zoneLivraisonById(int id) => '$apiUrl/vendeurs/zones-livraison/$id';

  // Produits
  static const String produitsRecherche = '$apiUrl/produits/recherche';
  static String produitBySlug(String slug) => '$apiUrl/produits/slug/$slug';
  static String produitById(int id) => '$apiUrl/produits/$id';
  static const String produits = '$apiUrl/produits';
  static String produitPhotoDelete(int id) => '$apiUrl/produits/$id/photo';

  // Commandes
  static const String commandes = '$apiUrl/commandes';
  static const String mesCommandes = '$apiUrl/commandes/mes-commandes';
  static String annulerCommande(int id) => '$apiUrl/commandes/$id/annuler';
  static const String commandesVendeur = '$apiUrl/commandes/vendeur';
  static String statutCommande(int id) => '$apiUrl/commandes/$id/statut';
  static String commandeDetail(int id) => '$apiUrl/commandes/$id';

  // Paiements
  static const String initierPaiement = '$apiUrl/paiements/initier';
  static String paiementCommande(int id) => '$apiUrl/paiements/commande/$id';
  static const String historiquePaiements = '$apiUrl/paiements/historique';

  // Livraisons
  static String livraisonCommande(int id) => '$apiUrl/livraisons/commande/$id';
  static const String livraisonsVendeur = '$apiUrl/livraisons/vendeur';

  // Dashboard
  static const String dashboard = '$apiUrl/dashboard';
  static const String dashboardStats = '$apiUrl/dashboard/statistiques';

  // Clients
  static const String clientProfil = '$apiUrl/clients/profil';
  static const String clientMotDePasse = '$apiUrl/clients/mot-de-passe';
  static const String clientHistorique = '$apiUrl/clients/historique';
  static String clientFacture(int id) => '$apiUrl/clients/facture/$id';

  // Notifications
  static const String notifications = '$apiUrl/notifications';
  static const String lireToutNotifications = '$apiUrl/notifications/lire-tout';
  static String lireNotification(int id) => '$apiUrl/notifications/$id/lire';
  static String supprimerNotification(int id) => '$apiUrl/notifications/$id';

  // Vérifications vendeur
  static const String verifications = '$apiUrl/verifications';
  static const String mesVerifications = '$apiUrl/verifications/mes-verifications';

  // Avis & Notation
  static const String avis = '$apiUrl/avis';
  static String avisVendeur(int vendeurId) => '$apiUrl/avis/vendeur/$vendeurId';
  static const String mesAvis = '$apiUrl/avis/mes-avis';
  static String repondreAvis(int id) => '$apiUrl/avis/$id/repondre';

  // Signalements
  static const String signalements = '$apiUrl/signalements';
  static const String mesSignalements = '$apiUrl/signalements/mes-signalements';

  // Premium
  static const String monPlan = '$apiUrl/premium/mon-plan';
  static const String souscrirePlan = '$apiUrl/premium/souscrire';
  static const String annulerPlan = '$apiUrl/premium/annuler';
  static const String stocksBas = '$apiUrl/premium/stocks-bas';

  // Uploads
  static String uploadUrl(String path) => '$baseUrl/$path';
}
