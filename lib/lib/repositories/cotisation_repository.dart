import 'package:sqflite/sqflite.dart';
import '../models/cotisation.dart';
import '../services/database_service.dart';

class CotisationRepository {
  final DatabaseService _databaseService;

  CotisationRepository(this._databaseService);

  Future<void> addCotisations(List<Cotisation> cotisations) async {
    final db = await _databaseService.database;
    for (var cotisation in cotisations) {
      // Vérifier si la cotisation existe déjà pour ce membre et ce mois
      var existingCotisation = await getCotisationByMembreAndMonth(
          cotisation.membreId, cotisation.mois);
      if (existingCotisation == null) {
        // Ajouter seulement si la cotisation n'existe pas déjà
        await db.insert('cotisations', cotisation.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<List<Cotisation>> getCotisationsByMembre(int membreId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db
        .query('cotisations', where: 'membreId = ?', whereArgs: [membreId]);
    return List.generate(maps.length, (i) => Cotisation.fromMap(maps[i]));
  }

  Future<Cotisation?> getCotisationByMembreAndMonth(
      int membreId, String mois) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cotisations',
      where: 'membreId = ? AND mois = ?',
      whereArgs: [membreId, mois],
    );
    if (maps.isNotEmpty) {
      return Cotisation.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getTotalCotisationByMembre(int membreId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
        'SELECT SUM(montant) as total FROM cotisations WHERE membreId = ?',
        [membreId]);

    return result.first['total'] as int? ?? 0;
  }
}
