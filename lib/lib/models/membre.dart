// lib/models/membre.dart
class Membre {
  int? id;
  String nom;
  String prenoms;
  String? photoPath; // Chemin vers l'image stockée localement
  DateTime dateNaissance;
  int age;
  String adresse;
  String telephone;
  DateTime? dateFva;
  bool baptise;
  DateTime? dateBapteme;
  int fiangonanaId;
  int? groupeId;

  Membre({
    this.id,
    required this.nom,
    required this.prenoms,
    this.photoPath,
    required this.dateNaissance,
    required this.age,
    required this.adresse,
    required this.telephone,
    this.dateFva,
    required this.baptise,
    this.dateBapteme,
    required this.fiangonanaId,
    this.groupeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenoms': prenoms,
      'photoPath': photoPath,
      'dateNaissance': dateNaissance.toIso8601String(),
      'age': age,
      'adresse': adresse,
      'telephone': telephone,
      'dateFva': dateFva?.toIso8601String(),
      'baptise': baptise ? 1 : 0,
      'dateBapteme': dateBapteme?.toIso8601String(),
      'fiangonanaId': fiangonanaId,
      'groupeId': groupeId,
    };
  }
}
