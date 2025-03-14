// lib/screens/groupe_form_screen.dart (complet)
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/groupe.dart';
import '../models/membre.dart';
import '../repositories/groupe_repository.dart';
import '../repositories/membre_repository.dart';
import '../services/database_service.dart';

class GroupeFormScreen extends StatefulWidget {
  final Groupe? groupe;

  GroupeFormScreen({this.groupe});

  @override
  _GroupeFormScreenState createState() => _GroupeFormScreenState();
}

class _GroupeFormScreenState extends State<GroupeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late GroupeRepository _groupeRepository;
  late MembreRepository _membreRepository;
  late TextEditingController _nomController;
  Membre? _selectedChef;
  List<Membre> _membres = [];

  @override
  void initState() {
    super.initState();
    _groupeRepository = GroupeRepository(DatabaseService());
    _membreRepository = MembreRepository(DatabaseService());
    _nomController =
        TextEditingController(text: widget.groupe?.nomGroupe ?? '');
    _loadMembres();
  }

  Future<void> _loadMembres() async {
    final membres = await _membreRepository.getAllMembres();
    setState(() {
      _membres = membres;
      if (widget.groupe != null && widget.groupe!.chefGroupeId != null) {
        _selectedChef = _membres.firstWhere(
          (membre) => membre.id == widget.groupe!.chefGroupeId,
          orElse: () => membres.isNotEmpty
              ? membres.first
              : Membre(
                  id: 0,
                  nom: 'Aucun',
                  prenoms: '',
                  dateNaissance: DateTime.now(),
                  age: 0,
                  adresse: '',
                  telephone: '',
                  baptise: false,
                  fiangonanaId: 0,
                ),
        );
      } else if (_membres.isNotEmpty) {
        _selectedChef = _membres.first;
      }
    });
  }

  Future<void> _saveGroupe() async {
    if (_formKey.currentState!.validate() && _selectedChef != null) {
      final groupe = Groupe(
        id: widget.groupe?.id,
        nomGroupe: _nomController.text,
        chefGroupeId: _selectedChef!.id!,
      );
      if (widget.groupe == null) {
        await _groupeRepository.insertGroupe(groupe);
      } else {
        await _groupeRepository.updateGroupe(groupe);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.groupe == null ? 'Ajouter un Groupe' : 'Modifier un Groupe',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du Groupe'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              SizedBox(height: 16),
              DropdownSearch<Membre>(
                items: _membres,
                itemAsString: (Membre? membre) =>
                    membre != null ? '${membre.nom} ${membre.prenoms}' : '',
                selectedItem: _selectedChef,
                onChanged: (Membre? membre) {
                  setState(() {
                    _selectedChef = membre;
                  });
                },
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem != null
                        ? '${selectedItem.nom} ${selectedItem.prenoms}'
                        : 'Sélectionner un chef',
                    style: TextStyle(fontFamily: 'Poppins'),
                  );
                },
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelText: 'Rechercher un membre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un chef' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGroupe,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE67E22)),
                child: Text('Sauvegarder',
                    style:
                        TextStyle(fontFamily: 'Poppins', color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
