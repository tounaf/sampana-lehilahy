// lib/repositories/fiangonana_repository.dart
import '../models/fiangonana.dart';
import '../services/database_service.dart';

class FiangonanaRepository {
  final DatabaseService _databaseService;

  FiangonanaRepository(this._databaseService);

  Future<List<Fiangonana>> getAllFiangonanas() async {
    return await _databaseService.getFiangonanas();
  }

  Future<void> insertFiangonana(Fiangonana fiangonana) async {
    await _databaseService.insertFiangonana(fiangonana);
  }

  Future<void> updateFiangonana(Fiangonana fiangonana) async {
    await _databaseService.updateFiangonana(fiangonana);
  }
}
