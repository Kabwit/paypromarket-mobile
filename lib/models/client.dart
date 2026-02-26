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
    return Client(
      id: json['id'],
      nomComplet: json['nom_complet'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      ville: json['ville'],
      province: json['province'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom_complet': nomComplet,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'ville': ville,
      'province': province,
    };
  }
}
