// lib/screens/membre_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/membre.dart';
import '../models/fiangonana.dart';
import '../models/groupe.dart';
import '../repositories/membre_repository.dart';
import '../repositories/fiangonana_repository.dart';
import '../repositories/groupe_repository.dart';
import '../services/database_service.dart';

class MembreFormScreen extends StatefulWidget {
  final Membre? membre;

  MembreFormScreen({this.membre});

  @override
  _MembreFormScreenState createState() => _MembreFormScreenState();
}

class _MembreFormScreenState extends State<MembreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MembreRepository _membreRepository;
  late FiangonanaRepository _fiangonanaRepository;
  late GroupeRepository _groupeRepository;

  late TextEditingController _nomController;
  late TextEditingController _prenomsController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;
  File? _photo;
  DateTime? _dateNaissance;
  DateTime? _dateFva;
  DateTime? _dateBapteme;
  bool _baptise = false;
  int? _fiangonanaId;
  int? _groupeId;
  List<Fiangonana> _fiangonanas = [];
  List<Groupe> _groupes = [];

  @override
  void initState() {
    super.initState();
    _membreRepository = MembreRepository(DatabaseService());
    _fiangonanaRepository = FiangonanaRepository(DatabaseService());
    _groupeRepository = GroupeRepository(DatabaseService());

    if (widget.membre != null) {
      _nomController = TextEditingController(text: widget.membre!.nom);
      _prenomsController = TextEditingController(text: widget.membre!.prenoms);
      _adresseController = TextEditingController(text: widget.membre!.adresse);
      _telephoneController =
          TextEditingController(text: widget.membre!.telephone);
      _photo = widget.membre!.photoPath != null
          ? File(widget.membre!.photoPath!)
          : null;
      _dateNaissance = widget.membre!.dateNaissance;
      _dateFva = widget.membre!.dateFva;
      _baptise = widget.membre!.baptise;
      _dateBapteme = widget.membre!.dateBapteme;
      _fiangonanaId = widget.membre!.fiangonanaId;
      _groupeId = widget.membre!.groupeId;
    } else {
      _nomController = TextEditingController();
      _prenomsController = TextEditingController();
      _adresseController = TextEditingController();
      _telephoneController = TextEditingController();
    }

    _loadFiangonanas();
    _loadGroupes();
  }

  Future<void> _loadFiangonanas() async {
    final fiangonanas = await _fiangonanaRepository.getAllFiangonanas();
    setState(() {
      _fiangonanas = fiangonanas;
      if (_fiangonanaId == null && fiangonanas.isNotEmpty) {
        _fiangonanaId = fiangonanas.first.id;
      }
    });
  }

  Future<void> _loadGroupes() async {
    final groupes = await _groupeRepository.getAllGroupes();
    setState(() {
      _groupes = groupes;
      // Pas de valeur par défaut pour groupe (optionnel)
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context,
      {required Function(DateTime) onDateSelected,
      DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _saveMembre() async {
    if (_formKey.currentState!.validate()) {
      final membre = Membre(
        id: widget.membre?.id,
        nom: _nomController.text,
        prenoms: _prenomsController.text,
        photoPath: _photo?.path,
        dateNaissance: _dateNaissance ?? DateTime.now(),
        age: _dateNaissance != null
            ? DateTime.now().year - _dateNaissance!.year
            : 0,
        adresse: _adresseController.text,
        telephone: _telephoneController.text,
        dateFva: _dateFva,
        baptise: _baptise,
        dateBapteme: _baptise ? _dateBapteme : null,
        fiangonanaId: _fiangonanaId!,
        groupeId: _groupeId,
      );

      if (widget.membre == null) {
        await _membreRepository.insertMembre(membre);
      } else {
        await _membreRepository.updateMembre(membre);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.membre == null ? 'Ajouter un Membre' : 'Modifier un Membre',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey[300]),
                  child: _photo != null
                      ? ClipOval(child: Image.file(_photo!, fit: BoxFit.cover))
                      : Icon(Icons.camera_alt, size: 40),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              TextFormField(
                controller: _prenomsController,
                decoration: InputDecoration(labelText: 'Prénoms'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer des prénoms' : null,
              ),
              ListTile(
                title: Text(_dateNaissance == null
                    ? 'Date de naissance'
                    : 'Date de naissance: ${_dateNaissance!.toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, onDateSelected: (date) {
                  setState(() => _dateNaissance = date);
                }, initialDate: _dateNaissance),
              ),
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une adresse' : null,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un téléphone' : null,
              ),
              DropdownButtonFormField<int>(
                value: _fiangonanaId,
                decoration: InputDecoration(labelText: 'Fiangonana'),
                items: _fiangonanas.map((fiangonana) {
                  return DropdownMenuItem<int>(
                    value: fiangonana.id,
                    child: Text(fiangonana.nomFiangonana),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _fiangonanaId = value),
                validator: (value) => value == null
                    ? 'Veuillez sélectionner une fiangonana'
                    : null,
              ),
              DropdownButtonFormField<int>(
                value: _groupeId,
                decoration: InputDecoration(labelText: 'Groupe (optionnel)'),
                items: _groupes.map((groupe) {
                  return DropdownMenuItem<int>(
                    value: groupe.id,
                    child: Text(groupe.nomGroupe),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _groupeId = value),
              ),
              ListTile(
                title: Text(_dateFva == null
                    ? 'Date FVA (optionnel)'
                    : 'Date FVA: ${_dateFva!.toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, onDateSelected: (date) {
                  setState(() => _dateFva = date);
                }, initialDate: _dateFva),
              ),
              SwitchListTile(
                title: Text('Baptisé'),
                value: _baptise,
                onChanged: (value) => setState(() => _baptise = value),
              ),
              if (_baptise)
                ListTile(
                  title: Text(_dateBapteme == null
                      ? 'Date de baptême'
                      : 'Date de baptême: ${_dateBapteme!.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, onDateSelected: (date) {
                    setState(() => _dateBapteme = date);
                  }, initialDate: _dateBapteme),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMembre,
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
