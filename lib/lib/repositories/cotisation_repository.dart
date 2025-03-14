// lib/repositories/cotisation_repository.dart
import 'package:sqflite/sqflite.dart';
import '../models/cotisation.dart';
import '../services/database_service.dart';

class CotisationRepository {
  final DatabaseService _databaseService;

  CotisationRepository(this._databaseService);

  Future<void> addCotisations(List<Cotisation> cotisations) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    for (var cotisation in cotisations) {
      // Vérifier si une cotisation ou un don existe déjà
      if (cotisation.mois != null) {
        // Cotisation mensuelle : vérifier par membreId et mois
        final existingCotisation = await getCotisationByMembreAndMonth(
          cotisation.membreId,
          cotisation.mois!,
        );
        if (existingCotisation == null) {
          batch.insert(
            'cotisation', // Nom de la table corrigé ici (cotisation, pas cotisations)
            cotisation.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      } else {
        // Don : insérer directement (pas de vérification d’unicité par mois)
        batch.insert(
          'cotisation',
          cotisation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<List<Cotisation>> getCotisationsByMembre(int membreId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cotisation', // Nom corrigé ici aussi
      where: 'membreId = ?',
      whereArgs: [membreId],
    );
    return List.generate(maps.length, (i) => Cotisation.fromMap(maps[i]));
  }

  Future<Cotisation?> getCotisationByMembreAndMonth(
      int membreId, String mois) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cotisation', // Nom corrigé
      where: 'membreId = ? AND mois = ?',
      whereArgs: [membreId, mois],
    );
    if (maps.isNotEmpty) {
      return Cotisation.fromMap(maps.first);
    }
    return null;
  }
}
