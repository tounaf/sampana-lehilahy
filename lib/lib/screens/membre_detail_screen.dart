// lib/screens/membre_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/membre.dart';
import '../models/fiangonana.dart';
import '../models/groupe.dart';
import '../repositories/fiangonana_repository.dart';
import '../repositories/groupe_repository.dart';
import '../services/database_service.dart';
import 'membre_form_screen.dart';

class MembreDetailScreen extends StatefulWidget {
  final Membre membre;

  MembreDetailScreen({required this.membre});

  @override
  _MembreDetailScreenState createState() => _MembreDetailScreenState();
}

class _MembreDetailScreenState extends State<MembreDetailScreen> {
  late FiangonanaRepository _fiangonanaRepository;
  late GroupeRepository _groupeRepository;

  @override
  void initState() {
    super.initState();
    _fiangonanaRepository = FiangonanaRepository(DatabaseService());
    _groupeRepository = GroupeRepository(DatabaseService());
  }

  Future<String> _getFiangonanaName(int fiangonanaId) async {
    final fiangonanas = await _fiangonanaRepository.getAllFiangonanas();
    final fiangonana = fiangonanas.firstWhere((f) => f.id == fiangonanaId,
        orElse: () =>
            Fiangonana(id: null, nomFiangonana: 'Non défini', adresse: ''));
    return fiangonana.nomFiangonana;
  }

  Future<String> _getGroupeName(int? groupeId) async {
    if (groupeId == null) return 'Non assigné';
    final groupes = await _groupeRepository.getAllGroupes();
    final groupe = groupes.firstWhere((g) => g.id == groupeId,
        orElse: () =>
            Groupe(id: null, nomGroupe: 'Non assigné', chefGroupeId: 0));
    return groupe.nomGroupe;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Détails du Membre', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MembreFormScreen(membre: widget.membre)),
              ).then((_) => Navigator.pop(context));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Color(0xFFF5F6FA),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  widget.membre.photoPath != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              FileImage(File(widget.membre.photoPath!)),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFFE67E22),
                          child: Text(
                            widget.membre.nom[0],
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                  SizedBox(height: 16),
                  Text(
                    '${widget.membre.nom} ${widget.membre.prenoms}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Âge: ${widget.membre.age}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Adresse', widget.membre.adresse),
                      _buildDetailRow('Téléphone', widget.membre.telephone),
                      _buildDetailRow(
                          'Date FVA',
                          widget.membre.dateFva?.toString().split(' ')[0] ??
                              'Non définie'),
                      _buildDetailRow(
                          'Baptisé', widget.membre.baptise ? 'Oui' : 'Non'),
                      if (widget.membre.baptise)
                        _buildDetailRow(
                            'Date de baptême',
                            widget.membre.dateBapteme
                                    ?.toString()
                                    .split(' ')[0] ??
                                'Non définie'),
                      FutureBuilder<String>(
                        future: _getFiangonanaName(widget.membre.fiangonanaId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildDetailRow(
                                'Fiangonana', 'Chargement...');
                          }
                          if (snapshot.hasError) {
                            return _buildDetailRow('Fiangonana', 'Erreur');
                          }
                          return _buildDetailRow(
                              'Fiangonana', snapshot.data ?? 'Non défini');
                        },
                      ),
                      FutureBuilder<String>(
                        future: _getGroupeName(widget.membre.groupeId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildDetailRow('Groupe', 'Chargement...');
                          }
                          if (snapshot.hasError) {
                            return _buildDetailRow('Groupe', 'Erreur');
                          }
                          return _buildDetailRow(
                              'Groupe', snapshot.data ?? 'Non assigné');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
