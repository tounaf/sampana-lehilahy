// lib/screens/groupe_list_screen.dart
import 'package:flutter/material.dart';
import '../models/groupe.dart';
import '../models/membre.dart';
import '../repositories/groupe_repository.dart';
import '../repositories/membre_repository.dart';
import '../services/database_service.dart';
import 'groupe_form_screen.dart';

class GroupeListScreen extends StatefulWidget {
  @override
  _GroupeListScreenState createState() => _GroupeListScreenState();
}

class _GroupeListScreenState extends State<GroupeListScreen> {
  late GroupeRepository _groupeRepository;
  late MembreRepository _membreRepository;

  @override
  void initState() {
    super.initState();
    _groupeRepository = GroupeRepository(DatabaseService());
    _membreRepository = MembreRepository(DatabaseService());
  }

  Future<String> _getChefName(int chefId) async {
    final membres = await _membreRepository.getAllMembres();
    final membre = membres.firstWhere((m) => m.id == chefId,
        orElse: () => Membre(
              id: 0,
              nom: 'Inconnu',
              prenoms: '',
              dateNaissance: DateTime.now(),
              age: 0,
              adresse: '',
              telephone: '',
              baptise: false,
              fiangonanaId: 0,
            ));
    return '${membre.nom} ${membre.prenoms}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Liste des Groupes', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: FutureBuilder<List<Groupe>>(
        future: _groupeRepository.getAllGroupes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFE67E22)));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erreur : ${snapshot.error}',
                    style: TextStyle(fontFamily: 'Poppins')));
          }
          final groupes = snapshot.data ?? [];
          if (groupes.isEmpty) {
            return Center(
              child: Text(
                'Aucun groupe enregistré',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: groupes.length,
            itemBuilder: (context, index) {
              final groupe = groupes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupeFormScreen(groupe: groupe)),
                  ).then((_) => setState(() {}));
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupe.nomGroupe,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getChefName(groupe.chefGroupeId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Chef: Chargement...',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors.grey[700]));
                            }
                            return Text(
                              'Chef: ${snapshot.data ?? 'Inconnu'}',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey[700]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupeFormScreen()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Color(0xFFE67E22),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
