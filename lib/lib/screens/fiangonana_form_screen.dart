// lib/screens/fiangonana_form_screen.dart
import 'package:flutter/material.dart';
import '../models/fiangonana.dart';
import '../repositories/fiangonana_repository.dart';
import '../services/database_service.dart';

class FiangonanaFormScreen extends StatefulWidget {
  final Fiangonana? fiangonana;

  FiangonanaFormScreen({this.fiangonana});

  @override
  _FiangonanaFormScreenState createState() => _FiangonanaFormScreenState();
}

class _FiangonanaFormScreenState extends State<FiangonanaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late FiangonanaRepository _fiangonanaRepository;
  late TextEditingController _nomController;
  late TextEditingController _adresseController;

  @override
  void initState() {
    super.initState();
    _fiangonanaRepository = FiangonanaRepository(DatabaseService());
    _nomController =
        TextEditingController(text: widget.fiangonana?.nomFiangonana ?? '');
    _adresseController =
        TextEditingController(text: widget.fiangonana?.adresse ?? '');
  }

  Future<void> _saveFiangonana() async {
    if (_formKey.currentState!.validate()) {
      final fiangonana = Fiangonana(
        id: widget.fiangonana?.id,
        nomFiangonana: _nomController.text,
        adresse: _adresseController.text,
      );
      if (widget.fiangonana == null) {
        await _fiangonanaRepository.insertFiangonana(fiangonana);
      } else {
        await _fiangonanaRepository.updateFiangonana(fiangonana);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fiangonana == null
                ? 'Ajouter une Fiangonana'
                : 'Modifier une Fiangonana',
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
                decoration: InputDecoration(labelText: 'Nom de la Fiangonana'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une adresse' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveFiangonana,
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
