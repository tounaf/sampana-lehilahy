import 'dart:io';
import 'package:flutter/material.dart';
import 'membre_form_screen.dart';
import 'membre_detail_screen.dart';
import 'cotisation_form_screen.dart';
import '../models/membre.dart';
import '../repositories/membre_repository.dart';
import '../services/database_service.dart';

class MembreListScreen extends StatefulWidget {
  @override
  _MembreListScreenState createState() => _MembreListScreenState();
}

class _MembreListScreenState extends State<MembreListScreen> {
  late MembreRepository _membreRepository;

  @override
  void initState() {
    super.initState();
    _membreRepository = MembreRepository(DatabaseService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Liste des Membres', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: FutureBuilder<List<Membre>>(
        future: _membreRepository.getAllMembres(),
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
          final membres = snapshot.data ?? [];
          if (membres.isEmpty) {
            return Center(
              child: Text(
                'Aucun membre enregistré',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: membres.length,
            itemBuilder: (context, index) {
              final membre = membres[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: membre.photoPath != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: FileImage(File(membre.photoPath!)),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFFE67E22),
                          child: Text(
                            membre.nom[0],
                            style: TextStyle(fontSize: 20, color: Colors.white),
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
                    icon: Icon(Icons.attach_money, color: Color(0xFFE67E22)),
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
          );
        },
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
