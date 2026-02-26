class AppNotification {
  final int? id;
  final String? titre;
  final String? message;
  final String? type;
  final bool? lue;
  final String? createdAt;

  AppNotification({
    this.id,
    this.titre,
    this.message,
    this.type,
    this.lue,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      titre: json['titre'],
      message: json['message'],
      type: json['type'],
      lue: json['lue'],
      createdAt: json['createdAt'],
    );
  }
}
