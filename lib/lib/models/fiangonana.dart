// lib/models/fiangonana.dart
class Fiangonana {
  int? id;
  String nomFiangonana;
  String adresse;

  Fiangonana({
    this.id,
    required this.nomFiangonana,
    required this.adresse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomFiangonana': nomFiangonana,
      'adresse': adresse,
    };
  }

  factory Fiangonana.fromMap(Map<String, dynamic> map) {
    return Fiangonana(
      id: map['id'],
      nomFiangonana: map['nomFiangonana'],
      adresse: map['adresse'],
    );
  }
}
