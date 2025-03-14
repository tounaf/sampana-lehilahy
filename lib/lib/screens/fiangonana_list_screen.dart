// lib/screens/fiangonana_list_screen.dart
import 'package:flutter/material.dart';
import '../models/fiangonana.dart';
import '../repositories/fiangonana_repository.dart';
import '../services/database_service.dart';
import 'fiangonana_form_screen.dart';

class FiangonanaListScreen extends StatefulWidget {
  @override
  _FiangonanaListScreenState createState() => _FiangonanaListScreenState();
}

class _FiangonanaListScreenState extends State<FiangonanaListScreen> {
  late FiangonanaRepository _fiangonanaRepository;

  @override
  void initState() {
    super.initState();
    _fiangonanaRepository = FiangonanaRepository(DatabaseService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Fiangonana',
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      body: FutureBuilder<List<Fiangonana>>(
        future: _fiangonanaRepository.getAllFiangonanas(),
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
          final fiangonanas = snapshot.data ?? [];
          if (fiangonanas.isEmpty) {
            return Center(
              child: Text(
                'Aucune fiangonana enregistrée',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.grey[600]),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: fiangonanas.length,
            itemBuilder: (context, index) {
              final fiangonana = fiangonanas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FiangonanaFormScreen(fiangonana: fiangonana)),
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
                          fiangonana.nomFiangonana,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Adresse: ${fiangonana.adresse}',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey[700]),
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
            MaterialPageRoute(builder: (context) => FiangonanaFormScreen()),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Color(0xFFE67E22),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
