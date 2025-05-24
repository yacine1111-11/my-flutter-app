import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrestataireService {
  final String id;
  final String nomComplet;
  final String email;
  final String numTel;
  final String adresse;
  final String nomService;
  final String specialite;
  final String typeAssurance;
  final String licenceNumero;
  final String licenceDateExpiration;
  final String userId;
  final String status;
  final String? rejectionReason;
  final Timestamp createdAt;

  PrestataireService({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.numTel,
    required this.adresse,
    required this.nomService,
    required this.specialite,
    required this.typeAssurance,
    required this.licenceNumero,
    required this.licenceDateExpiration,
    required this.userId,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory PrestataireService.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrestataireService(
      id: doc.id,
      nomComplet: data['nomComplet'] ?? '',
      email: data['email'] ?? '',
      numTel: data['numTel'] ?? '',
      adresse: data['adresse'] ?? '',
      nomService: data['nomService'] ?? '',
      specialite: data['specialite'] ?? '',
      typeAssurance: data['typeAssurance'] ?? '',
      licenceNumero: data['licenceNumero'] ?? '',
      licenceDateExpiration: data['licenceDateExpiration'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'En attente',
      rejectionReason: data['rejectionReason'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomComplet': nomComplet,
      'email': email,
      'numTel': numTel,
      'adresse': adresse,
      'nomService': nomService,
      'specialite': specialite,
      'typeAssurance': typeAssurance,
      'licenceNumero': licenceNumero,
      'licenceDateExpiration': licenceDateExpiration,
      'userId': userId,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
    };
  }
}

class ServiceProvidersScreen extends StatefulWidget {
  @override
  _ServiceProvidersScreenState createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PrestataireService> _prestataires = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadPrestataires();
  }

  Future<void> _loadPrestataires() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('demandesDepanage')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _prestataires = snapshot.docs
            .map((doc) => PrestataireService.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur de chargement: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des données')),
      );
    }
  }

  Future<void> _updateStatus(String docId, String newStatus,
      {String? rejectionReason}) async {
    try {
      await _firestore.collection('demandesDepanage').doc(docId).update({
        'status': newStatus,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });
      await _loadPrestataires();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }

  void _showProviderDetails(PrestataireService prestataire) {
    TextEditingController rejectionController = TextEditingController(
      text: prestataire.rejectionReason ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Détails prestataire #${prestataire.id}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('État: ${prestataire.status}',
                      style: TextStyle(
                          color: _getStatusColor(prestataire.status),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text('Informations principales:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('- Service: ${prestataire.nomService}'),
                  Text('- Spécialité: ${prestataire.specialite}'),
                  Text('- Type assurance: ${prestataire.typeAssurance}'),
                  Divider(),
                  Text('Coordonnées:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('- Nom: ${prestataire.nomComplet}'),
                  Text('- Téléphone: ${prestataire.numTel}'),
                  Text('- Email: ${prestataire.email}'),
                  Text('- Adresse: ${prestataire.adresse}'),
                  Divider(),
                  Text('Licence commerciale:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('- Numéro: ${prestataire.licenceNumero}'),
                  Text('- Expiration: ${prestataire.licenceDateExpiration}'),
                  Divider(),
                  if (prestataire.status == 'En attente') ...[
                    TextField(
                      controller: rejectionController,
                      decoration: InputDecoration(
                        labelText: 'Motif de rejet (si applicable)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                  ],
                  if (prestataire.rejectionReason != null) ...[
                    Text('Motif de rejet:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(prestataire.rejectionReason!),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            actions: [
              if (prestataire.status == 'En attente') ...[
                TextButton(
                  onPressed: () {
                    if (rejectionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Veuillez saisir un motif')),
                      );
                      return;
                    }
                    _updateStatus(
                      prestataire.id,
                      'Rejeté',
                      rejectionReason: rejectionController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Rejeter', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    _updateStatus(prestataire.id, 'Accepté');
                    Navigator.pop(context);
                  },
                  child:
                      Text('Accepter', style: TextStyle(color: Colors.green)),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepté':
        return Colors.green;
      case 'Rejeté':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  List<PrestataireService> _filterPrestataires() {
    List<PrestataireService> filtered = _prestataires;

    if (_filterStatus != 'Tous') {
      filtered = filtered.where((p) => p.status == _filterStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.nomComplet.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.nomService.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.licenceNumero
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              p.status.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrestataires = _filterPrestataires();

    return Scaffold(
      appBar: AppBar(
        title: Text('Prestataires de service'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPrestataires,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilter('Tous'),
                _buildStatusFilter('En attente'),
                _buildStatusFilter('Accepté'),
                _buildStatusFilter('Rejeté'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPrestataires.isEmpty
                    ? Center(child: Text('Aucun prestataire trouvé'))
                    : ListView.builder(
                        itemCount: filteredPrestataires.length,
                        itemBuilder: (context, index) {
                          final prestataire = filteredPrestataires[index];
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(prestataire.nomService),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prestataire.nomComplet),
                                  Text(
                                    prestataire.status,
                                    style: TextStyle(
                                      color:
                                          _getStatusColor(prestataire.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () => _showProviderDetails(prestataire),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String status) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(status),
        selected: _filterStatus == status,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? status : 'Tous';
          });
        },
      ),
    );
  }
}
