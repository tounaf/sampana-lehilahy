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
  int _totalPaid = 0;
  String _badge = "En retard 🟥";

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

  @override
  void initState() {
    super.initState();
    _cotisationRepository = CotisationRepository(DatabaseService());

    for (var month in _months) {
      _controllers[month] = TextEditingController();
      _paidMonths[month] = false;
    }

    _loadCotisations();
  }

  Future<void> _loadCotisations() async {
    List<Cotisation> cotisations =
        await _cotisationRepository.getCotisationsByMembre(widget.membre.id!);

    _totalPaid = await _cotisationRepository
        .getTotalCotisationByMembre(widget.membre.id!);
    _badge = getBadge(_totalPaid);

    for (var cotisation in cotisations) {
      _controllers[cotisation.mois]?.text = cotisation.montant.toString();
      _paidMonths[cotisation.mois] = true;
    }

    setState(() {});
  }

  String getBadge(int totalPaid) {
    if (totalPaid < 6000) {
      return "En retard 🟥";
    } else if (totalPaid < 12000) {
      return "À jour 🟨";
    } else {
      return "Excellent 🟩";
    }
  }

  void _saveCotisation() async {
    List<Cotisation> cotisations = [];
    for (var month in _months) {
      int amount = int.tryParse(_controllers[month]!.text) ?? 0;
      if (amount > 0) {
        var existingCotisation = await _cotisationRepository
            .getCotisationByMembreAndMonth(widget.membre.id!, month);
        if (existingCotisation == null) {
          cotisations.add(Cotisation(
            membreId: widget.membre.id!,
            mois: month,
            montant: amount,
          ));
          _paidMonths[month] = true;
        }
      }
    }

    if (cotisations.isNotEmpty) {
      await _cotisationRepository.addCotisations(cotisations);
      _loadCotisations(); // Recharger les données pour mettre à jour le badge
    }
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

            // Badge de statut
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(
                  _badge,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                backgroundColor: _badge == "En retard 🟥"
                    ? Colors.red
                    : _badge == "À jour 🟨"
                        ? Colors.orange
                        : Colors.green,
                padding: EdgeInsets.all(8.0),
              ),
            ),

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
