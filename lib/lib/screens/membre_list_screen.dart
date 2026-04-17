import 'dart:io';
import 'package:flutter/material.dart';
import 'membre_form_screen.dart';
import 'membre_detail_screen.dart';
import 'cotisation_form_screen.dart';
import '../models/membre.dart';
import '../models/groupe.dart';
import '../repositories/membre_repository.dart';
import '../repositories/groupe_repository.dart';
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
  int? _selectedGroupeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _membreRepository = MembreRepository(DatabaseService());
    _groupeRepository = GroupeRepository(DatabaseService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final groupes = await _groupeRepository.getAllGroupes();
    final membres = await _membreRepository.getAllMembres();

    setState(() {
      _groupes = groupes;
      _membres = membres;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedGroupeId == null) {
      _filteredMembres = _membres;
    } else {
      _filteredMembres = _membres
          .where((membre) => membre.groupeId == _selectedGroupeId)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Membres', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : Column(
              children: [
                if (_groupes.isNotEmpty)
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
                              _applyFilter();
                            });
                          },
                          selectedColor: const Color(0xFFE67E22),
                          backgroundColor: const Color(0xFFBDC3C7),
                          labelStyle: TextStyle(
                            color: _selectedGroupeId == groupe.id ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Total : ${_filteredMembres.length} membre(s)',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredMembres.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun membre trouvé',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _filteredMembres.length,
                          itemBuilder: (context, index) {
                            final membre = _filteredMembres[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: membre.photoPath != null
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundImage: FileImage(File(membre.photoPath!)),
                                      )
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundColor: const Color(0xFFE67E22),
                                        child: Text(
                                          membre.nom[0],
                                          style: const TextStyle(fontSize: 20, color: Colors.white),
                                        ),
                                      ),
                                title: Text(
                                  '${membre.nom} ${membre.prenoms}',
                                  style: const TextStyle(
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
                                        builder: (context) => MembreDetailScreen(membre: membre)),
                                  ).then((_) => _loadData());
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.attach_money, color: Color(0xFFE67E22)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CotisationFormScreen(membre: membre),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MembreFormScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFFE67E22),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
