class ApiConfig {
  // API base URL - configurable via --dart-define en ligne de commande
  // Exemples d'utilisation:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000    (Android Emulator)
  //   flutter run --dart-define=API_BASE_URL=http://localhost:5000   (iOS Simulator)
  //   flutter run --dart-define=API_BASE_URL=http://192.168.1.100:5000 (Device sur réseau)
  static String get baseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
  
  static String get apiUrl => '$baseUrl/api';

  // Auth
  static String get vendeurInscription => '$apiUrl/auth/vendeur/inscription';
  static String get vendeurConnexion => '$apiUrl/auth/vendeur/connexion';
  static String get clientInscription => '$apiUrl/auth/client/inscription';
  static String get clientConnexion => '$apiUrl/auth/client/connexion';
  static String get profil => '$apiUrl/auth/profil';

  // Vendeurs
  static String get boutiques => '$apiUrl/vendeurs/boutiques';
  static String boutiqueBySlug(String slug) => '$apiUrl/vendeurs/boutique/$slug';
  static String get vendeurProfil => '$apiUrl/vendeurs/profil';
  static String get vendeurLogo => '$apiUrl/vendeurs/logo';
  static String get zonesLivraison => '$apiUrl/vendeurs/zones-livraison';
  static String zoneLivraisonById(int id) => '$apiUrl/vendeurs/zones-livraison/$id';

  // Produits
  static String get produitsRecherche => '$apiUrl/produits/recherche';
  static String produitBySlug(String slug) => '$apiUrl/produits/slug/$slug';
  static String produitById(int id) => '$apiUrl/produits/$id';
  static String get produits => '$apiUrl/produits';
  static String produitPhotoDelete(int id) => '$apiUrl/produits/$id/photo';

  // Commandes
  static String get commandes => '$apiUrl/commandes';
  static String get mesCommandes => '$apiUrl/commandes/mes-commandes';
  static String annulerCommande(int id) => '$apiUrl/commandes/$id/annuler';
  static String get commandesVendeur => '$apiUrl/commandes/vendeur';
  static String statutCommande(int id) => '$apiUrl/commandes/$id/statut';
  static String commandeDetail(int id) => '$apiUrl/commandes/$id';

  // Paiements
  static String get initierPaiement => '$apiUrl/paiements/initier';
  static String paiementCommande(int id) => '$apiUrl/paiements/commande/$id';
  static String get historiquePaiements => '$apiUrl/paiements/historique';

  // Livraisons
  static String livraisonCommande(int id) => '$apiUrl/livraisons/commande/$id';
  static String get livraisonsVendeur => '$apiUrl/livraisons/vendeur';

  // Dashboard
  static String get dashboard => '$apiUrl/dashboard';
  static String get dashboardStats => '$apiUrl/dashboard/statistiques';

  // Clients
  static String get clientProfil => '$apiUrl/clients/profil';
  static String get clientMotDePasse => '$apiUrl/clients/mot-de-passe';
  static String get clientHistorique => '$apiUrl/clients/historique';
  static String clientFacture(int id) => '$apiUrl/clients/facture/$id';

  // Notifications
  static String get notifications => '$apiUrl/notifications';
  static String get lireToutNotifications => '$apiUrl/notifications/lire-tout';
  static String lireNotification(int id) => '$apiUrl/notifications/$id/lire';
  static String supprimerNotification(int id) => '$apiUrl/notifications/$id';

  // Vérifications vendeur
  static String get verifications => '$apiUrl/verifications';
  static String get mesVerifications => '$apiUrl/verifications/mes-verifications';

  // Avis & Notation
  static String get avis => '$apiUrl/avis';
  static String avisVendeur(int vendeurId) => '$apiUrl/avis/vendeur/$vendeurId';
  static String get mesAvis => '$apiUrl/avis/mes-avis';
  static String repondreAvis(int id) => '$apiUrl/avis/$id/repondre';

  // Signalements
  static String get signalements => '$apiUrl/signalements';
  static String get mesSignalements => '$apiUrl/signalements/mes-signalements';

  // Premium
  static String get monPlan => '$apiUrl/premium/mon-plan';
  static String get souscrirePlan => '$apiUrl/premium/souscrire';
  static String get annulerPlan => '$apiUrl/premium/annuler';
  static String get stocksBas => '$apiUrl/premium/stocks-bas';

  // Chat / Messagerie
  static String get chatConversations => '$apiUrl/chat/conversations';
  static String chatMessages(String conversationId) => '$apiUrl/chat/conversations/$conversationId';
  static String get chatEnvoyer => '$apiUrl/chat/envoyer';
  static String get chatDemarrer => '$apiUrl/chat/demarrer';
  static String get fcmToken => '$apiUrl/auth/fcm-token';

  // Uploads
  static String uploadUrl(String path) => '$baseUrl/$path';
}
