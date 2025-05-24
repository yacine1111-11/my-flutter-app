import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DemandeAssurance {
  final String id;
  final String nomComplet;
  final String email;
  final String telephone;
  final String adresse;
  final String dateNaissance;
  final String marqueVehicule;
  final String modeleVehicule;
  final String matriculation;
  final String anneeVehicule;
  final String numeroChassis;
  final String carteGrise;
  final String numeroPermis;
  final String categoriePermis;
  final String statut;
  final List<Map<String, dynamic>> photos;
  final String? contratUrl;
  final Timestamp? dateContrat;
  final Timestamp timestamp;

  DemandeAssurance({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.dateNaissance,
    required this.marqueVehicule,
    required this.modeleVehicule,
    required this.matriculation,
    required this.anneeVehicule,
    required this.numeroChassis,
    required this.carteGrise,
    required this.numeroPermis,
    required this.categoriePermis,
    required this.statut,
    required this.photos,
    this.contratUrl,
    this.dateContrat,
    required this.timestamp,
  });

  factory DemandeAssurance.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DemandeAssurance(
      id: doc.id,
      nomComplet: data['nomComplet'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      adresse: data['adresse'] ?? '',
      dateNaissance: data['dateNaissance'] ?? '',
      marqueVehicule: data['marqueVehicule'] ?? '',
      modeleVehicule: data['modeleVehicule'] ?? 'Non spécifié',
      matriculation: data['matriculation'] ?? '',
      anneeVehicule: data['anneeVehicule'] ?? '',
      numeroChassis: data['numeroChassis'] ?? '',
      carteGrise: data['carteGrise'] ?? '',
      numeroPermis: data['numeroPermis'] ?? '',
      categoriePermis: data['categoriePermis'] ?? '',
      statut: data['statut'] ?? 'En attente',
      photos: List<Map<String, dynamic>>.from(data['photos'] ?? []),
      contratUrl: data['contratUrl'],
      dateContrat: data['dateContrat'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomComplet': nomComplet,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
      'marqueVehicule': marqueVehicule,
      'modeleVehicule': modeleVehicule,
      'matriculation': matriculation,
      'anneeVehicule': anneeVehicule,
      'numeroChassis': numeroChassis,
      'carteGrise': carteGrise,
      'numeroPermis': numeroPermis,
      'categoriePermis': categoriePermis,
      'statut': statut,
      'photos': photos,
      'contratUrl': contratUrl,
      'dateContrat': dateContrat,
      'timestamp': timestamp,
    };
  }
}

class DemandesAssuranceScreen extends StatefulWidget {
  @override
  _DemandesAssuranceScreenState createState() =>
      _DemandesAssuranceScreenState();
}

class _DemandesAssuranceScreenState extends State<DemandesAssuranceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  List<DemandeAssurance> _demandes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('demandes_assurance')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _demandes = snapshot.docs
            .map((doc) => DemandeAssurance.fromFirestore(doc))
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

  Future<void> _updateStatut(String docId, String newStatut,
      {String? rejectionReason,
      String? contratUrl,
      Timestamp? dateContrat}) async {
    try {
      Map<String, dynamic> updateData = {
        'statut': newStatut,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        if (contratUrl != null) 'contratUrl': contratUrl,
        if (dateContrat != null) 'dateContrat': dateContrat,
      };

      await _firestore
          .collection('demandes_assurance')
          .doc(docId)
          .update(updateData);
      _loadDemandes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }

  Future<void> _uploadImage(String docId, XFile image, String type) async {
    try {
      final ref = _storage.ref().child(
          'demandes/$docId/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(image.path));
      String url = await ref.getDownloadURL();

      await _firestore.collection('demandes_assurance').doc(docId).update({
        'photos': FieldValue.arrayUnion([
          {
            'type': type,
            'url': url,
            'description': 'Photo $type',
            'date': DateTime.now().toString(),
          }
        ])
      });

      _loadDemandes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload de l\'image')),
      );
    }
  }

  Future<void> _uploadContrat(String docId, File contratFile) async {
    try {
      final ref = _storage.ref().child(
          'contrats/$docId/contrat_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await ref.putFile(contratFile);
      String url = await ref.getDownloadURL();

      await _updateStatut(
        docId,
        'Accepté',
        contratUrl: url,
        dateContrat: Timestamp.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contrat uploadé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'upload du contrat: $e')),
      );
    }
  }

  Widget _buildPhotoGrid(List<Map<String, dynamic>> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullImage(photos[index]['url']),
          child: Image.network(
            photos[index]['url'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
        );
      },
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDemandeDetails(DemandeAssurance demande) {
    TextEditingController rejectionController = TextEditingController();
    File? _contratFile;

    Future<void> _pickContrat() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _contratFile = File(result.files.single.path!);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Détails demande #${demande.id}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations personnelles',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Nom: ${demande.nomComplet}'),
                  Text('Email: ${demande.email}'),
                  Text('Téléphone: ${demande.telephone}'),
                  Text('Adresse: ${demande.adresse}'),
                  Text('Date de naissance: ${demande.dateNaissance}'),
                  Divider(),
                  Text('Informations véhicule',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Marque: ${demande.marqueVehicule}'),
                  Text('Modèle: ${demande.modeleVehicule}'),
                  Text('Année: ${demande.anneeVehicule}'),
                  Text('Matricule: ${demande.matriculation}'),
                  Text('N° Chassis: ${demande.numeroChassis}'),
                  Text('Carte grise: ${demande.carteGrise}'),
                  Divider(),
                  Text('Informations permis',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('N° Permis: ${demande.numeroPermis}'),
                  Text('Catégorie: ${demande.categoriePermis}'),
                  Divider(),
                  Text('Statut: ${demande.statut}',
                      style: TextStyle(
                        color: _getStatusColor(demande.statut),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                  if (demande.contratUrl != null) ...[
                    Divider(),
                    Text('Contrat d\'assurance',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        'Date d\'émission: ${demande.dateContrat?.toDate().toString() ?? 'N/A'}'),
                    ElevatedButton(
                      onPressed: () {
                        // Ouvrir le contrat PDF
                        // Vous pouvez utiliser un package comme flutter_pdf_viewer
                      },
                      child: Text('Voir le contrat'),
                    ),
                  ],
                  SizedBox(height: 16),
                  if (demande.photos.isNotEmpty) ...[
                    Text('Photos:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildPhotoGrid(demande.photos),
                    SizedBox(height: 16),
                  ],
                  if (demande.statut == 'En attente') ...[
                    Divider(),
                    TextField(
                      controller: rejectionController,
                      decoration: InputDecoration(
                        labelText: 'Motif de rejet (si applicable)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Text('Contrat obligatoire:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _pickContrat,
                      child: Text('Sélectionner le contrat PDF'),
                    ),
                    if (_contratFile != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Fichier sélectionné: ${_contratFile!.path.split('/').last}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            actions: [
              if (demande.statut == 'En attente') ...[
                TextButton(
                  onPressed: () {
                    if (rejectionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Veuillez saisir un motif de rejet')),
                      );
                      return;
                    }
                    _updateStatut(demande.id, 'Rejeté',
                        rejectionReason: rejectionController.text);
                    Navigator.pop(context);
                  },
                  child: Text('Rejeter', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    if (_contratFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Veuillez sélectionner un contrat')),
                      );
                      return;
                    }
                    _uploadContrat(demande.id, _contratFile!);
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

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'accepté':
        return Colors.green;
      case 'rejeté':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  List<DemandeAssurance> _filterDemandes() {
    if (_searchQuery.isEmpty) return _demandes;
    return _demandes
        .where((demande) =>
            demande.nomComplet
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            demande.matriculation
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            demande.marqueVehicule
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            demande.statut.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDemandes = _filterDemandes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes d\'assurance'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDemandes,
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
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredDemandes.isEmpty
                    ? Center(child: Text('Aucune demande trouvée'))
                    : ListView.builder(
                        itemCount: filteredDemandes.length,
                        itemBuilder: (context, index) {
                          final demande = filteredDemandes[index];
                          return Card(
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(demande.nomComplet),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${demande.marqueVehicule} ${demande.modeleVehicule}'),
                                  Text(
                                    'Matricule: ${demande.matriculation}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    demande.statut,
                                    style: TextStyle(
                                      color: _getStatusColor(demande.statut),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (demande.contratUrl != null)
                                    Text(
                                      'Contrat disponible',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () => _showDemandeDetails(demande),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
