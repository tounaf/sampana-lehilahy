import 'package:sqflite/sqflite.dart';
import '../models/cotisation.dart';
import '../services/database_service.dart';

class CotisationRepository {
  final DatabaseService _databaseService;

  CotisationRepository(this._databaseService);

  Future<void> addCotisations(List<Cotisation> cotisations) async {
    final db = await _databaseService.database;
    for (var cotisation in cotisations) {
      await db.insert('cotisations', cotisation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Cotisation>> getCotisationsByMembre(int membreId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db
        .query('cotisations', where: 'membreId = ?', whereArgs: [membreId]);
    return List.generate(maps.length, (i) => Cotisation.fromMap(maps[i]));
  }
}
