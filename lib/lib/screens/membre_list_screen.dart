import 'dart:io';
import 'package:flutter/material.dart';
import 'membre_form_screen.dart';
import 'membre_detail_screen.dart';
import 'cotisation_form_screen.dart';
import '../models/membre.dart';
import '../models/groupe.dart'; // Importer le modèle Groupe
import '../repositories/membre_repository.dart';
import '../repositories/groupe_repository.dart'; // Importer le GroupeRepository
import '../services/database_service.dart';

class MembreListScreen extends StatefulWidget {
  @override
  _MembreListScreenState createState() => _MembreListScreenState();
}

class _MembreListScreenState extends State<MembreListScreen> {
  late MembreRepository _membreRepository;
  late GroupeRepository _groupeRepository;
  List<Groupe> _groupes = [];
  List<Membre> _membres = [];
  List<Membre> _filteredMembres = [];
  int _totalMembers = 0;
  int? _selectedGroupeId; // Variable pour savoir quel groupe est sélectionné

  @override
  void initState() {
    super.initState();
    _membreRepository = MembreRepository(DatabaseService());
    _groupeRepository = GroupeRepository(DatabaseService());
    _loadData();
  }

  // Charger les groupes et membres
  void _loadData() async {
    final groupes =
        await _groupeRepository.getAllGroupes(); // Récupérer tous les groupes
    final membres =
        await _membreRepository.getAllMembres(); // Récupérer tous les membres

    setState(() {
      _groupes = groupes;
      _membres = membres;
      _filteredMembres = membres;
      _totalMembers = membres.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Liste des Membres', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (_groupes.isEmpty || _membres.isEmpty) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFE67E22)));
          }
          return Column(
            children: [
              // Afficher les groupes sous forme de badges
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _groupes.map((groupe) {
                    return ChoiceChip(
                      label: Text(groupe.nomGroupe),
                      selected: _selectedGroupeId == groupe.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGroupeId = selected ? groupe.id : null;
                          _filteredMembres = selected
                              ? _membres
                                  .where(
                                      (membre) => membre.groupeId == groupe.id)
                                  .toList()
                              : _membres;
                          _totalMembers = _filteredMembres.length;
                        });
                      },
                      selectedColor: Color(0xFFE67E22),
                      backgroundColor: Color(0xFFBDC3C7),
                    );
                  }).toList(),
                ),
              ),
              // Afficher le total des membres
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total des membres : $_totalMembers',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Liste des membres filtrée
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _filteredMembres.length,
                  itemBuilder: (context, index) {
                    final membre = _filteredMembres[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: membre.photoPath != null
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    FileImage(File(membre.photoPath!)),
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFE67E22),
                                child: Text(
                                  membre.nom[0],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                        title: Text(
                          '${membre.nom} ${membre.prenoms}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        subtitle: Text(
                          'Âge: ${membre.age} | Tél: ${membre.telephone}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MembreDetailScreen(membre: membre)),
                          ).then((_) => setState(() {}));
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.attach_money,
                              color: Color(0xFFE67E22)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CotisationFormScreen(membre: membre),
                              ),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        future: null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MembreFormScreen()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Color(0xFFE67E22),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
