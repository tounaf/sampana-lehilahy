class Cotisation {
  int? id;
  int membreId;
  String mois;
  int montant;

  Cotisation(
      {this.id,
      required this.membreId,
      required this.mois,
      required this.montant});

  Map<String, dynamic> toMap() {
    return {'membreId': membreId, 'mois': mois, 'montant': montant};
  }

  static Cotisation fromMap(Map<String, dynamic> map) {
    return Cotisation(
      id: map['id'],
      membreId: map['membreId'],
      mois: map['mois'],
      montant: map['montant'],
    );
  }
}
