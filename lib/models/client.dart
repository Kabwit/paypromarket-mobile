class Client {
  final int? id;
  final String nomComplet;
  final String telephone;
  final String? email;
  final String? adresse;
  final String? ville;
  final String? province;
  final String? createdAt;

  Client({
    this.id,
    required this.nomComplet,
    required this.telephone,
    this.email,
    this.adresse,
    this.ville,
    this.province,
    this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    // Backend envoie 'nom' + 'prenom' séparément
    String fullName = json['nom_complet'] ?? '';
    if (fullName.isEmpty) {
      final nom = json['nom'] ?? '';
      final prenom = json['prenom'] ?? '';
      fullName = '$nom $prenom'.trim();
    }
    return Client(
      id: json['id'],
      nomComplet: fullName,
      telephone: json['telephone'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      ville: json['ville'],
      province: json['province'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    // Backend attend 'nom' (pas 'nom_complet')
    return {
      'nom': nomComplet,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'ville': ville,
      'province': province,
    };
  }
}
