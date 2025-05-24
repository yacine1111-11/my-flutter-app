import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Classes Modèle
class Assuree {
  final String nomComplet;
  final String email;
  final String numTEL;
  final String adresse;
  final String dateNaissance;
  final String numCarte;
  final String ccp;

  Assuree({
    required this.nomComplet,
    required this.email,
    required this.numTEL,
    required this.adresse,
    required this.dateNaissance,
    required this.numCarte,
    required this.ccp,
  });

  factory Assuree.fromMap(Map<String, dynamic> data) {
    return Assuree(
      nomComplet: data['nomComplet'] ?? '',
      email: data['email'] ?? '',
      numTEL: data['numTEL'] ?? '',
      adresse: data['adresse'] ?? '',
      dateNaissance: data['dateNaissance'] ?? '',
      numCarte: data['numCarte'] ?? '',
      ccp: data['ccp'] ?? '',
    );
  }
}

class Vehicule {
  final String marque;
  final String modele;
  final String annee;
  final String matriculation;
  final String kilometrage;
  final String couleur;
  final String numeroChassis;
  final List<Map<String, String>> photos;

  Vehicule({
    required this.marque,
    required this.modele,
    required this.annee,
    required this.matriculation,
    required this.kilometrage,
    required this.couleur,
    required this.numeroChassis,
    required this.photos,
  });

  factory Vehicule.fromMap(Map<String, dynamic> data) {
    return Vehicule(
      marque: data['marque'] ?? '',
      modele: data['modele'] ?? '',
      annee: data['annee'] ?? '',
      matriculation: data['matriculation'] ?? '',
      kilometrage: data['kilometrage'] ?? '',
      couleur: data['couleur'] ?? '',
      numeroChassis: data['numeroChassis'] ?? '',
      photos: List<Map<String, String>>.from(data['photos'] ?? []),
    );
  }
}

class Permis {
  final String categorie;
  final String carteGrise;
  final String dateDebut;
  final String dateExpiration;
  final List<Map<String, String>> photos;

  Permis({
    required this.categorie,
    required this.carteGrise,
    required this.dateDebut,
    required this.dateExpiration,
    required this.photos,
  });

  factory Permis.fromMap(Map<String, dynamic> data) {
    return Permis(
      categorie: data['categorie'] ?? '',
      carteGrise: data['carteGrise'] ?? '',
      dateDebut: data['dateDebut'] ?? '',
      dateExpiration: data['dateExpiration'] ?? '',
      photos: List<Map<String, String>>.from(data['photos'] ?? []),
    );
  }
}

class Request {
  final String id;
  final Assuree assuree;
  final Vehicule vehicule;
  final Permis permis;
  final String insuranceType;
  final String status;
  final String rejectionReason;
  final List<Map<String, String>> acceptanceImage;
  final Timestamp submittedAt;

  Request({
    required this.id,
    required this.assuree,
    required this.vehicule,
    required this.permis,
    required this.insuranceType,
    required this.status,
    required this.rejectionReason,
    required this.acceptanceImage,
    required this.submittedAt,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      assuree: Assuree.fromMap(data['assuree'] ?? {}),
      vehicule: Vehicule.fromMap(data['vehicule'] ?? {}),
      permis: Permis.fromMap(data['permis'] ?? {}),
      insuranceType: data['insuranceType'] ?? '',
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'] ?? '',
      acceptanceImage:
          List<Map<String, String>>.from(data['acceptanceImage'] ?? []),
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
    );
  }
}

// 2. Classe principale avec Firestore
class RequestListPage extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterStatus = 'accepté';

  Stream<QuerySnapshot> _getRequestsStream() {
    return _firestore
        .collection('declarations_accidents')
        .where('status', isEqualTo: _filterStatus)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  Future<void> _updateRequestStatus(String id, String status,
      {String reason = ''}) async {
    try {
      await _firestore.collection('declarations_accidents').doc(id).update({
        'status': status,
        'rejectionReason': reason,
        'processedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Demandes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
              stream: _getRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucune demande trouvée'));
                }

                final requests = snapshot.data!.docs.map((doc) {
                  return Request.fromFirestore(doc);
                }).toList();

                final filteredRequests = requests.where((req) {
                  final search = _searchController.text.toLowerCase();
                  return req.assuree.nomComplet
                          .toLowerCase()
                          .contains(search) ||
                      req.vehicule.matriculation.toLowerCase().contains(search);
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
                        title: Text(req.assuree.nomComplet),
                        subtitle:
                            Text('Matricule: ${req.vehicule.matriculation}'),
                        trailing: Icon(
                          req.status == 'accepté'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: req.status == 'accepté'
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () => _showRequestDetails(context, req),
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = 'accepté'),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    _filterStatus == 'accepté' ? Colors.green[50] : null,
                side: BorderSide(color: Colors.green),
              ),
              child: Text('Accepté', style: TextStyle(color: Colors.green)),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = 'refusé'),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    _filterStatus == 'refusé' ? Colors.red[50] : null,
                side: BorderSide(color: Colors.red),
              ),
              child: Text('Refusé', style: TextStyle(color: Colors.red)),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = ''),
              style: OutlinedButton.styleFrom(
                backgroundColor: _filterStatus.isEmpty ? Colors.blue[50] : null,
                side: BorderSide(color: Colors.blue),
              ),
              child: Text('Tous', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrer les demandes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('Acceptées'),
                value: 'accepté',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text('Refusées'),
                value: 'refusé',
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value.toString());
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text('Toutes'),
                value: '',
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

  void _showRequestDetails(BuildContext context, Request req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Détails de la Demande',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),

              // Section Assuré
              _buildDetailSection(
                title: 'Informations Assuré',
                items: [
                  'Nom: ${req.assuree.nomComplet}',
                  'Email: ${req.assuree.email}',
                  'Téléphone: ${req.assuree.numTEL}',
                  'Adresse: ${req.assuree.adresse}',
                  'Date Naissance: ${req.assuree.dateNaissance}',
                  'Numéro Carte: ${req.assuree.numCarte}',
                  'CCP: ${req.assuree.ccp}',
                ],
              ),

              // Section Véhicule
              _buildDetailSection(
                title: 'Informations Véhicule',
                items: [
                  'Marque: ${req.vehicule.marque}',
                  'Modèle: ${req.vehicule.modele}',
                  'Année: ${req.vehicule.annee}',
                  'Matricule: ${req.vehicule.matriculation}',
                  'Kilométrage: ${req.vehicule.kilometrage} km',
                  'Couleur: ${req.vehicule.couleur}',
                  'Châssis: ${req.vehicule.numeroChassis}',
                ],
              ),

              // Section Photos Véhicule
              if (req.vehicule.photos.isNotEmpty) ...[
                Text('Photos du Véhicule',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: req.vehicule.photos.length,
                  itemBuilder: (context, index) {
                    final photo = req.vehicule.photos[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            photo['imageUrl'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(photo['angle'] ?? ''),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
              ],

              // Section Permis
              _buildDetailSection(
                title: 'Informations Permis',
                items: [
                  'Catégorie: ${req.permis.categorie}',
                  'Carte Grise: ${req.permis.carteGrise}',
                  'Date Début: ${req.permis.dateDebut}',
                  'Date Expiration: ${req.permis.dateExpiration}',
                ],
              ),

              // Section Photos Permis
              if (req.permis.photos.isNotEmpty) ...[
                Text('Photos du Permis',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: req.permis.photos.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      req.permis.photos[index]['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                    );
                  },
                ),
                SizedBox(height: 16),
              ],

              // Section Statut
              _buildDetailSection(
                title: 'Statut',
                items: [
                  'Type Assurance: ${req.insuranceType}',
                  'Statut: ${req.status}',
                  if (req.status == 'refusé') 'Raison: ${req.rejectionReason}',
                ],
              ),

              // Boutons d'action
              if (req.status == 'pending') ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _rejectRequest(context, req.id),
                        child: Text('Refuser',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _acceptRequest(context, req.id),
                        child: Text('Accepter',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
      {required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(item),
                ))
            .toList(),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> _acceptRequest(BuildContext context, String requestId) async {
    await _updateRequestStatus(requestId, 'accepté');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demande acceptée avec succès')),
    );
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
              onPressed: () async {
                if (reasonController.text.isNotEmpty) {
                  await _updateRequestStatus(
                    requestId,
                    'refusé',
                    reason: reasonController.text,
                  );
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  Navigator.pop(context); // Fermer le bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Demande refusée avec succès')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
