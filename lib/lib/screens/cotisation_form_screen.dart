// lib/screens/cotisation_form_screen.dart
import 'package:flutter/material.dart';
import '../models/membre.dart';
import '../models/cotisation.dart';
import '../repositories/cotisation_repository.dart';
import '../services/database_service.dart';

class CotisationFormScreen extends StatefulWidget {
  final Membre membre;

  const CotisationFormScreen({required this.membre, super.key});

  @override
  _CotisationFormScreenState createState() => _CotisationFormScreenState();
}

class _CotisationFormScreenState extends State<CotisationFormScreen> {
  late CotisationRepository _cotisationRepository;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _paidMonths = {};
  final TextEditingController _donAmountController = TextEditingController();
  final TextEditingController _donDescriptionController =
      TextEditingController();
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
    'Décembre',
  ];
  List<Cotisation> _dons = [];

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
    final cotisations =
        await _cotisationRepository.getCotisationsByMembre(widget.membre.id!);
    setState(() {
      _dons.clear(); // Réinitialiser la liste des dons
      for (var cotisation in cotisations) {
        if (cotisation.mois != null) {
          _controllers[cotisation.mois!]?.text = cotisation.montant.toString();
          _paidMonths[cotisation.mois!] = true;
        } else if (cotisation.description != null) {
          _dons.add(cotisation);
        }
      }
    });
  }

  Future<void> _saveCotisation() async {
    final List<Cotisation> cotisationsToAdd = [];

    // Cotisations mensuelles
    for (var month in _months) {
      final amountText = _controllers[month]!.text.trim();
      final amount = int.tryParse(amountText) ?? 0;
      if (amount > 0 && !_paidMonths[month]!) {
        cotisationsToAdd.add(Cotisation(
          membreId: widget.membre.id!,
          mois: month,
          montant: amount,
        ));
        _paidMonths[month] = true; // Marquer comme payé localement
        _controllers[month]!.clear(); // Vider le champ après ajout
      }
    }

    // Don ponctuel
    final donAmountText = _donAmountController.text.trim();
    final donAmount = int.tryParse(donAmountText) ?? 0;
    final donDescription = _donDescriptionController.text.trim();
    if (donAmount > 0 && donDescription.isNotEmpty) {
      final don = Cotisation(
        membreId: widget.membre.id!,
        montant: donAmount,
        description: donDescription,
      );
      cotisationsToAdd.add(don);
      _dons.add(don);
      _donAmountController.clear();
      _donDescriptionController.clear();
    }

    if (cotisationsToAdd.isNotEmpty) {
      try {
        await _cotisationRepository.addCotisations(cotisationsToAdd);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cotisations et dons enregistrés avec succès')),
        );
        setState(() {}); // Rafraîchir l’affichage
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l’enregistrement : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Aucune nouvelle cotisation ou don à enregistrer')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _donAmountController.dispose();
    _donDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotisations de ${widget.membre.nom}',
            style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.membre.nom} ${widget.membre.prenoms}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _months.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final month = _months[index];
                        return TextField(
                          controller: _controllers[month],
                          keyboardType: TextInputType.number,
                          enabled: !_paidMonths[month]!,
                          decoration: InputDecoration(
                            labelText: month,
                            suffixIcon: _paidMonths[month]!
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                            border: const OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ajouter un don',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _donAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Montant du don',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _donDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description du don',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_dons.isNotEmpty) ...[
                      const Text(
                        'Dons effectués',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dons.length,
                        itemBuilder: (context, index) {
                          final don = _dons[index];
                          return ListTile(
                            title: Text('Montant: ${don.montant}',
                                style: const TextStyle(fontFamily: 'Poppins')),
                            subtitle: Text(don.description ?? '',
                                style: const TextStyle(fontFamily: 'Poppins')),
                            trailing: const Icon(Icons.check_circle,
                                color: Colors.green),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveCotisation,
        backgroundColor: const Color(0xFFE67E22),
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
