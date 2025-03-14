import 'package:flutter/material.dart';
import '../models/membre.dart';
import '../models/cotisation.dart';
import '../repositories/cotisation_repository.dart';
import '../services/database_service.dart';

class CotisationFormScreen extends StatefulWidget {
  final Membre membre;
  CotisationFormScreen({required this.membre});

  @override
  _CotisationFormScreenState createState() => _CotisationFormScreenState();
}

class _CotisationFormScreenState extends State<CotisationFormScreen> {
  late CotisationRepository _cotisationRepository;
  Map<String, TextEditingController> _controllers = {};
  Map<String, bool> _paidMonths = {};

  @override
  void initState() {
    super.initState();
    _cotisationRepository = CotisationRepository(DatabaseService());

    for (var month in _months) {
      _controllers[month] = TextEditingController();
      _paidMonths[month] = false;
    }
  }

  final List<String> _months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre'
  ];

  void _saveCotisation() async {
    List<Cotisation> cotisations = [];
    for (var month in _months) {
      int amount = int.tryParse(_controllers[month]!.text) ?? 0;
      if (amount > 0) {
        cotisations.add(Cotisation(
          membreId: widget.membre.id!,
          mois: month,
          montant: amount,
        ));
        _paidMonths[month] = true;
      }
    }
    await _cotisationRepository.addCotisations(cotisations);
    setState(() {}); // Mettre à jour l'affichage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cotisation de ${widget.membre.nom}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('${widget.membre.nom} ${widget.membre.prenoms}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: GridView.builder(
                itemCount: _months.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 3),
                itemBuilder: (context, index) {
                  String month = _months[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controllers[month],
                      keyboardType: TextInputType.number,
                      enabled: !_paidMonths[month]!,
                      decoration: InputDecoration(
                        labelText: month,
                        suffixIcon: _paidMonths[month]!
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveCotisation,
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }
}
