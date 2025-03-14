// lib/models/cotisation.dart
class Cotisation {
  int? id;
  int membreId;
  String? mois; // Nullable pour les dons
  int montant;
  String? description; // Nouveau champ pour les dons

  Cotisation({
    this.id,
    required this.membreId,
    this.mois,
    required this.montant,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'membreId': membreId,
      'mois': mois,
      'montant': montant,
      'description': description,
    };
  }

  factory Cotisation.fromMap(Map<String, dynamic> map) {
    return Cotisation(
      id: map['id'],
      membreId: map['membreId'],
      mois: map['mois'],
      montant: map['montant'],
      description: map['description'],
    );
  }
}
