import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Depannage {
  final String id;
  final String nomComplet;
  final String numeroContact;
  final String email;
  final String adresse;
  final String licenceNumero;
  final String licenceDateExpiration;
  final String status;
  final String? specialite;
  final String? nomService;
  final String? userId;

  Depannage({
    required this.id,
    required this.nomComplet,
    required this.numeroContact,
    required this.email,
    required this.adresse,
    required this.licenceNumero,
    required this.licenceDateExpiration,
    required this.status,
    this.specialite,
    this.nomService,
    this.userId,
  });

  factory Depannage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Depannage(
      id: doc.id,
      nomComplet: data['nomComplet'] ?? '',
      numeroContact: data['numTel'] ?? '',
      email: data['email'] ?? '',
      adresse: data['adresse'] ?? '',
      licenceNumero: data['licenceNumero'] ?? '',
      licenceDateExpiration: data['licenceDateExpiration'] ?? '',
      status: data['status'] ?? 'en attente',
      specialite: data['specialite'],
      nomService: data['nomService'],
      userId: data['userId'],
    );
  }
}

class Deppanagelist extends StatefulWidget {
  @override
  _DeppanagelistState createState() => _DeppanagelistState();
}

class _DeppanagelistState extends State<Deppanagelist> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filterStatus = 'Accepté'; // Correspond aux valeurs dans Firestore

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Dépanneurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
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
                labelText: 'Rechercher par nom',
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
              onChanged: (value) => setState(() {}),
            ),
          ),
          _buildStatusFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('demandesDepanage')
                  .where('status', isEqualTo: _filterStatus)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun dépanneur trouvé'));
                }

                final depanneurs = snapshot.data!.docs
                    .map((doc) => Depannage.fromFirestore(doc))
                    .where((depannage) => depannage.nomComplet
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: depanneurs.length,
                  itemBuilder: (context, index) {
                    final depannage = depanneurs[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 4,
                      child: ListTile(
                        title: Text(depannage.nomComplet,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(depannage.adresse),
                        trailing: Icon(
                          depannage.status == 'Accepté'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: depannage.status == 'Accepté'
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () => _showDepannageDetails(context, depannage),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = 'Accepté'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _filterStatus == 'Accepté' ? Colors.white : Colors.green,
                backgroundColor:
                    _filterStatus == 'Accepté' ? Colors.green : Colors.white,
                side: BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Acceptés'),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = 'Refusé'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _filterStatus == 'Refusé' ? Colors.white : Colors.red,
                backgroundColor:
                    _filterStatus == 'Refusé' ? Colors.red : Colors.white,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Refusés'),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _filterStatus = 'en attente'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _filterStatus == 'en attente' ? Colors.white : Colors.blue,
                backgroundColor:
                    _filterStatus == 'en attente' ? Colors.blue : Colors.white,
                side: BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('En attente'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepannageDetails(BuildContext context, Depannage depannage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails du Dépanneur'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem('Nom complet', depannage.nomComplet),
                _buildDetailItem('Email', depannage.email),
                _buildDetailItem('Téléphone', depannage.numeroContact),
                _buildDetailItem('Adresse', depannage.adresse),
                _buildDetailItem('Numéro permis', depannage.licenceNumero),
                _buildDetailItem(
                    'Date expiration permis', depannage.licenceDateExpiration),
                _buildDetailItem('Statut', depannage.status),
                if (depannage.specialite != null)
                  _buildDetailItem('Spécialité', depannage.specialite!),
                if (depannage.nomService != null)
                  _buildDetailItem('Service', depannage.nomService!),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.pop(context),
            ),
            if (depannage.status != 'Accepté')
              TextButton(
                child: Text('Accepter', style: TextStyle(color: Colors.green)),
                onPressed: () => _updateStatus(depannage.id, 'Accepté'),
              ),
            if (depannage.status != 'Refusé')
              TextButton(
                child: Text('Refuser', style: TextStyle(color: Colors.red)),
                onPressed: () => _updateStatus(depannage.id, 'Refusé'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('demandesDepanage').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context); // Ferme le dialogue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}
