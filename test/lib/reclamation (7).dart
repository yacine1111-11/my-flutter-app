import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AssurPlus - Gestion des Accidents',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E5BFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E5BFF),
          secondary: Color(0xFF6B7C93),
        ),
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.all(16),
        ),
      ),
      home: const DemandesAccidentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AccidentReport {
  final String id;
  final String date;
  final String heure;
  final String description;
  final String descriptionDegats;
  final String lieu;
  final String idContrat;
  final String nomContrat;
  final bool aAutreConducteur;
  final Map<String, dynamic>? infoAutreConducteur;
  final bool constatAmiable;
  final bool rapportPolice;
  final Timestamp envoyeLe;
  final int nombrePhotos;
  final String statut;

  AccidentReport({
    required this.id,
    required this.date,
    required this.heure,
    required this.description,
    required this.descriptionDegats,
    required this.lieu,
    required this.idContrat,
    required this.nomContrat,
    required this.aAutreConducteur,
    this.infoAutreConducteur,
    required this.constatAmiable,
    required this.rapportPolice,
    required this.envoyeLe,
    required this.nombrePhotos,
    required this.statut,
  });

  factory AccidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AccidentReport(
      id: doc.id,
      date: data['date'] ?? '',
      heure: data['heure'] ?? '',
      description: data['description'] ?? '',
      descriptionDegats: data['descriptionDegats'] ?? '',
      lieu: data['lieu'] ?? '',
      idContrat: data['idContrat'] ?? '',
      nomContrat: data['nomContrat'] ?? 'Contrat Auto',
      aAutreConducteur: data['aAutreConducteur'] ?? false,
      infoAutreConducteur: data['infoAutreConducteur'] is Map
          ? Map<String, dynamic>.from(data['infoAutreConducteur'])
          : null,
      constatAmiable: data['constatAmiable'] ?? false,
      rapportPolice: data['rapportPolice'] ?? false,
      envoyeLe: data['envoyeLe'] ?? Timestamp.now(),
      nombrePhotos: data['nombrePhotos'] ?? 0,
      statut: data['statut'] ?? 'en_attente',
    );
  }
}

class DemandesAccidentScreen extends StatefulWidget {
  const DemandesAccidentScreen({super.key});

  @override
  State<DemandesAccidentScreen> createState() => _DemandesAccidentScreenState();
}

class _DemandesAccidentScreenState extends State<DemandesAccidentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'en_attente';
  bool _isLoading = false;

  // Liste des assets d'images de démonstration
  final List<String> _demoPhotos = [
    'accident1.jpg',
    'accident2.jpg',
  ];

  Stream<QuerySnapshot> _getReportsStream() {
    return _firestore
        .collection('declarations_accidents')
        .orderBy('envoyeLe', descending: true)
        .snapshots();
  }

  Future<void> _updateReportStatus(String id, String status,
      {String? reason}) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('declarations_accidents').doc(id).update({
        'statut': status,
        if (reason != null) 'motifRejet': reason,
        'traiteLe': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Déclarations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _isLoading
              ? const LinearProgressIndicator()
              : Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getReportsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Aucune déclaration'));
                      }

                      final reports = snapshot.data!.docs.map((doc) {
                        return AccidentReport.fromFirestore(doc);
                      }).where((report) {
                        // Filtre par statut
                        final statusMatch = _filterStatus.isEmpty ||
                            report.statut == _filterStatus;

                        // Filtre par recherche
                        final search = _searchController.text.toLowerCase();
                        final searchMatch = search.isEmpty ||
                            report.description.toLowerCase().contains(search) ||
                            report.lieu.toLowerCase().contains(search);

                        return statusMatch && searchMatch;
                      }).toList();

                      if (reports.isEmpty) {
                        return const Center(child: Text('Aucun résultat'));
                      }

                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return _buildReportCard(report);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReportCard(AccidentReport report) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Déclaration #${report.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    report.statut == 'en_attente'
                        ? 'En attente'
                        : report.statut == 'acceptee'
                            ? 'Acceptée'
                            : 'Rejetée',
                  ),
                  backgroundColor: report.statut == 'en_attente'
                      ? Colors.orange[100]
                      : report.statut == 'acceptee'
                          ? Colors.green[100]
                          : Colors.red[100],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Date:', '${report.date} à ${report.heure}'),
            _buildInfoRow('Lieu:', report.lieu),
            _buildInfoRow('Contrat:', report.nomContrat),
            _buildInfoRow('Description:', report.description),
            _buildInfoRow('Dégâts:', report.descriptionDegats),
            _buildInfoRow(
                'Documents:',
                '${report.constatAmiable ? 'Constat amiable' : ''}'
                    '${report.constatAmiable && report.rapportPolice ? ' + ' : ''}'
                    '${report.rapportPolice ? 'Rapport de police' : ''}'
                    '${!report.constatAmiable && !report.rapportPolice ? 'Aucun' : ''}'),
            if (report.aAutreConducteur &&
                report.infoAutreConducteur != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Autre conducteur:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildInfoRow('Nom:',
                  report.infoAutreConducteur!['nom'] ?? 'Non renseigné'),
              _buildInfoRow('Assurance:',
                  report.infoAutreConducteur!['assurance'] ?? 'Non renseigné'),
            ],
            if (report.nombrePhotos > 0) ...[
              const SizedBox(height: 12),
              const Text(
                'Photos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _demoPhotos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () =>
                            _showFullScreenImage(context, _demoPhotos[index]),
                        child: Image.asset(
                          _demoPhotos[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (report.statut == 'en_attente') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateReportStatus(report.id, 'acceptee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Accepter',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(report.id),
                      child: const Text('Rejeter',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(String reportId) async {
    final reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Motif du rejet'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Entrez la raison du rejet...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  _updateReportStatus(reportId, 'rejetee',
                      reason: reasonController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFullScreenImage(
      BuildContext context, String imagePath) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les déclarations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('Toutes'),
                value: '',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('En attente'),
                value: 'en_attente',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('Acceptées'),
                value: 'acceptee',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: const Text('Rejetées'),
                value: 'rejetee',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
