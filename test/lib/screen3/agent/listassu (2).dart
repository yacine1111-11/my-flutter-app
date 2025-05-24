import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsuranceRequest {
  final String id;
  final String nomComplet;
  final String email;
  final String telephone;
  final String adresse;
  final String dateNaissance;
  final String numCarteNationale;
  final String ccp;
  final String marqueVehicule;
  final String modeleVehicule;
  final String anneeVehicule;
  final String matriculation;
  final String kilometrage;
  final String numeroChassis;
  final String categoriePermis;
  final String numeroPermis;
  final String carteGrise;
  final String dateDebutPermis;
  final String dateExpirationPermis;
  final String methodePaiement;
  final String detailsPaiement;
  final String typeAssurance;
  final String statut;
  final String rejectionReason;
  final Timestamp timestamp;

  InsuranceRequest({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.dateNaissance,
    required this.numCarteNationale,
    required this.ccp,
    required this.marqueVehicule,
    required this.modeleVehicule,
    required this.anneeVehicule,
    required this.matriculation,
    required this.kilometrage,
    required this.numeroChassis,
    required this.categoriePermis,
    required this.numeroPermis,
    required this.carteGrise,
    required this.dateDebutPermis,
    required this.dateExpirationPermis,
    required this.methodePaiement,
    required this.detailsPaiement,
    required this.typeAssurance,
    required this.statut,
    required this.rejectionReason,
    required this.timestamp,
  });

  factory InsuranceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InsuranceRequest(
      id: doc.id,
      nomComplet: data['nomComplet'] ?? 'Non spécifié',
      email: data['email'] ?? 'Non spécifié',
      telephone: data['telephone'] ?? 'Non spécifié',
      adresse: data['adresse'] ?? 'Non spécifié',
      dateNaissance: data['dateNaissance'] ?? 'Non spécifié',
      numCarteNationale: data['numCarteNationale'] ?? 'Non spécifié',
      ccp: data['ccp'] ?? 'Non spécifié',
      marqueVehicule: data['marqueVehicule'] ?? 'Non spécifié',
      modeleVehicule:
          data['modele'] ?? 'Non spécifié', // Note: field name difference
      anneeVehicule: data['anneeVehicule'] ?? 'Non spécifié',
      matriculation: data['matriculation'] ?? 'Non spécifié',
      kilometrage: data['kilometrage'] ?? 'Non spécifié',
      numeroChassis: data['numeroChassis'] ?? 'Non spécifié',
      categoriePermis: data['categoriePermis'] ?? 'Non spécifié',
      numeroPermis: data['numeroPermis'] ?? 'Non spécifié',
      carteGrise: data['carteGrise'] ?? 'Non spécifié',
      dateDebutPermis: data['dateDebutPermis'] ?? 'Non spécifié',
      dateExpirationPermis: data['dateExpirationPermis'] ?? 'Non spécifié',
      methodePaiement: data['methodePaiement'] ?? 'Non spécifié',
      detailsPaiement: data['detailsPaiement'] ?? 'Non spécifié',
      typeAssurance: data['typeAssurance'] ?? 'Non spécifié',
      statut: data['statut'] ?? 'En attente',
      rejectionReason: data['rejectionReason'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class RequestListPage extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Accepté'; // Changed to match your status values
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Demandes d\'Assurance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par nom ou matricule',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          _buildStatusFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('demandes_assurance').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Erreur de chargement des données'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune demande trouvée'));
                }

                final requests = snapshot.data!.docs
                    .map((doc) {
                      return InsuranceRequest.fromFirestore(doc);
                    })
                    .where((req) => req.statut == _filterStatus)
                    .toList();

                final filteredRequests = requests.where((req) {
                  final search = _searchController.text.toLowerCase();
                  return req.nomComplet.toLowerCase().contains(search) ||
                      req.matriculation.toLowerCase().contains(search);
                }).toList();

                if (filteredRequests.isEmpty) {
                  return Center(child: Text('Aucun résultat trouvé'));
                }

                return ListView.builder(
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final req = filteredRequests[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(req.nomComplet),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Matricule: ${req.matriculation}'),
                            Text('Type: ${req.typeAssurance}'),
                            Text('Date: ${req.timestamp.toDate().toString()}'),
                          ],
                        ),
                        trailing: Icon(
                          req.statut == 'Accepté'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: req.statut == 'Accepté'
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () => _navigateBasedOnStatus(context, req),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _filterStatus == 'Accepté'
                    ? Colors.green.withOpacity(0.2)
                    : null,
              ),
              onPressed: () => setState(() => _filterStatus = 'Accepté'),
              child: Text('Accepté',
                  style: TextStyle(
                    color: _filterStatus == 'Accepté'
                        ? Colors.green
                        : Colors.black,
                  )),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _filterStatus == 'Refusé'
                    ? Colors.red.withOpacity(0.2)
                    : null,
              ),
              onPressed: () => setState(() => _filterStatus = 'Refusé'),
              child: Text('Refusé',
                  style: TextStyle(
                    color:
                        _filterStatus == 'Refusé' ? Colors.red : Colors.black,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateBasedOnStatus(BuildContext context, InsuranceRequest req) {
    if (req.statut == 'Accepté') {
      _showAcceptedRequestDetails(context, req);
    } else if (req.statut == 'Refusé') {
      _showRejectedRequestDetails(context, req);
    } else {
      _showPendingRequestDetails(context, req);
    }
  }

  void _showAcceptedRequestDetails(BuildContext context, InsuranceRequest req) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Détails - Accepté'),
            backgroundColor: Colors.green,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  title: 'Informations Personnelles',
                  children: [
                    _buildDetailItem('Nom Complet', req.nomComplet),
                    _buildDetailItem('Email', req.email),
                    _buildDetailItem('Téléphone', req.telephone),
                    _buildDetailItem('Adresse', req.adresse),
                    _buildDetailItem('Date de Naissance', req.dateNaissance),
                    _buildDetailItem(
                        'Numéro Carte Nationale', req.numCarteNationale),
                    _buildDetailItem('CCP', req.ccp),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  title: 'Informations Véhicule',
                  children: [
                    _buildDetailItem('Marque', req.marqueVehicule),
                    _buildDetailItem('Modèle', req.modeleVehicule),
                    _buildDetailItem('Année', req.anneeVehicule),
                    _buildDetailItem('Matricule', req.matriculation),
                    _buildDetailItem('Kilométrage', req.kilometrage),
                    _buildDetailItem('Numéro Châssis', req.numeroChassis),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  title: 'Informations Permis',
                  children: [
                    _buildDetailItem('Catégorie', req.categoriePermis),
                    _buildDetailItem('Numéro Permis', req.numeroPermis),
                    _buildDetailItem('Carte Grise', req.carteGrise),
                    _buildDetailItem('Date Début', req.dateDebutPermis),
                    _buildDetailItem(
                        'Date Expiration', req.dateExpirationPermis),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  title: 'Paiement',
                  children: [
                    _buildDetailItem('Méthode', req.methodePaiement),
                    _buildDetailItem('Détails', req.detailsPaiement),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRejectedRequestDetails(BuildContext context, InsuranceRequest req) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Détails - Refusé'),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  title: 'Raison du Refus',
                  children: [
                    Text(
                      req.rejectionReason.isNotEmpty
                          ? req.rejectionReason
                          : 'Aucune raison spécifiée',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  title: 'Informations Personnelles',
                  children: [
                    _buildDetailItem('Nom Complet', req.nomComplet),
                    _buildDetailItem('Email', req.email),
                    _buildDetailItem('Téléphone', req.telephone),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  title: 'Informations Véhicule',
                  children: [
                    _buildDetailItem('Marque', req.marqueVehicule),
                    _buildDetailItem('Matricule', req.matriculation),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPendingRequestDetails(BuildContext context, InsuranceRequest req) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la Demande'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Nom Complet', req.nomComplet),
                _buildDetailItem('Matricule', req.matriculation),
                _buildDetailItem('Type Assurance', req.typeAssurance),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Refuser', style: TextStyle(color: Colors.red)),
              onPressed: () => _rejectRequest(context, req.id),
            ),
            TextButton(
              child: Text('Accepter', style: TextStyle(color: Colors.green)),
              onPressed: () => _acceptRequest(context, req.id),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context, String requestId) async {
    try {
      await _firestore.collection('demandes_assurance').doc(requestId).update({
        'statut': 'Accepté',
        'processedAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande acceptée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectRequest(BuildContext context, String requestId) async {
    final reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Raison du refus'),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Entrez la raison du refus',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Confirmer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  _updateRequestStatus(
                    requestId,
                    'Refusé',
                    rejectionReason: reasonController.text.trim(),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context); // Close both dialogs
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateRequestStatus(
    String requestId,
    String status, {
    String rejectionReason = '',
  }) async {
    try {
      await _firestore.collection('demandes_assurance').doc(requestId).update({
        'statut': status,
        'rejectionReason': rejectionReason,
        'processedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande $status avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}
