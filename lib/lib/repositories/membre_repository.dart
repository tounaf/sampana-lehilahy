// lib/repositories/membre_repository.dart
import '../models/membre.dart';
import '../services/database_service.dart';

class MembreRepository {
  final DatabaseService _databaseService;

  MembreRepository(this._databaseService);

  Future<List<Membre>> getAllMembres() async {
    return await _databaseService.getMembres();
  }

  Future<void> insertMembre(Membre membre) async {
    await _databaseService.insertMembre(membre);
  }

  Future<void> updateMembre(Membre membre) async {
    await _databaseService.updateMembre(membre);
  }
}
