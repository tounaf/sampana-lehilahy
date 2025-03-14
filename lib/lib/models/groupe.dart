// lib/models/groupe.dart
class Groupe {
  int? id;
  String nomGroupe;
  int chefGroupeId;

  Groupe({
    this.id,
    required this.nomGroupe,
    required this.chefGroupeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomGroupe': nomGroupe,
      'chefGroupeId': chefGroupeId,
    };
  }

  factory Groupe.fromMap(Map<String, dynamic> map) {
    return Groupe(
      id: map['id'],
      nomGroupe: map['nomGroupe'],
      chefGroupeId: map['chefGroupeId'],
    );
  }
}
