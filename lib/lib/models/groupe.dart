// lib/models/groupe.dart
class Groupe {
  int? id;
  String nomGroupe;
  int chefGroupeId; // Référence à un membre

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
}
