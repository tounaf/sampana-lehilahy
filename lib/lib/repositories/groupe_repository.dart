// lib/repositories/groupe_repository.dart
import '../models/groupe.dart';
import '../services/database_service.dart';

class GroupeRepository {
  final DatabaseService _databaseService;

  GroupeRepository(this._databaseService);

  Future<List<Groupe>> getAllGroupes() async {
    return await _databaseService.getGroupes();
  }

  Future<void> insertGroupe(Groupe groupe) async {
    await _databaseService.insertGroupe(groupe);
  }

  Future<void> updateGroupe(Groupe groupe) async {
    await _databaseService.updateGroupe(groupe);
  }
}
