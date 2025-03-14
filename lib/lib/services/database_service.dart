// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/membre.dart';
import '../models/fiangonana.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sampana.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fiangonana (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomFiangonana TEXT,
            adresse TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE membre (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenoms TEXT,
            photoPath TEXT,
            dateNaissance TEXT,
            age INTEGER,
            adresse TEXT,
            telephone TEXT,
            dateFva TEXT,
            baptise INTEGER,
            dateBapteme TEXT,
            fiangonanaId INTEGER,
            groupeId INTEGER,
            FOREIGN KEY (fiangonanaId) REFERENCES fiangonana(id)
          )
        ''');
      },
    );
  }

  // Méthodes pour Membre
  Future<void> insertMembre(Membre membre) async {
    final db = await database;
    await db.insert('membre', membre.toMap());
  }

  Future<List<Membre>> getMembres() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('membre');
    return List.generate(maps.length, (i) {
      return Membre(
        id: maps[i]['id'],
        nom: maps[i]['nom'],
        prenoms: maps[i]['prenoms'],
        photoPath: maps[i]['photoPath'],
        dateNaissance: DateTime.parse(maps[i]['dateNaissance']),
        age: maps[i]['age'],
        adresse: maps[i]['adresse'],
        telephone: maps[i]['telephone'],
        dateFva: maps[i]['dateFva'] != null
            ? DateTime.parse(maps[i]['dateFva'])
            : null,
        baptise: maps[i]['baptise'] == 1,
        dateBapteme: maps[i]['dateBapteme'] != null
            ? DateTime.parse(maps[i]['dateBapteme'])
            : null,
        fiangonanaId: maps[i]['fiangonanaId'],
        groupeId: maps[i]['groupeId'],
      );
    });
  }

  Future<void> updateMembre(Membre membre) async {
    final db = await database;
    await db.update('membre', membre.toMap(),
        where: 'id = ?', whereArgs: [membre.id]);
  }

  // Méthodes pour Fiangonana
  Future<void> insertFiangonana(Fiangonana fiangonana) async {
    final db = await database;
    await db.insert('fiangonana', fiangonana.toMap());
  }

  Future<List<Fiangonana>> getFiangonanas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fiangonana');
    return List.generate(maps.length, (i) => Fiangonana.fromMap(maps[i]));
  }

  Future<void> updateFiangonana(Fiangonana fiangonana) async {
    final db = await database;
    await db.update('fiangonana', fiangonana.toMap(),
        where: 'id = ?', whereArgs: [fiangonana.id]);
  }
}
