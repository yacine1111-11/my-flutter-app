import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractManagementScreen extends StatefulWidget {
  @override
  _ContractManagementScreenState createState() =>
      _ContractManagementScreenState();
}

class _ContractManagementScreenState extends State<ContractManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _offersCollection =
      FirebaseFirestore.instance.collection('offers');

  List<Map<String, dynamic>> activeOffers = [];
  List<Map<String, dynamic>> renewedOffers = [];
  List<Map<String, dynamic>> archivedOffers = [];
  bool isLoading = true;
  String? selectedPhoto;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _offersCollection.get();

      setState(() {
        activeOffers = snapshot.docs
            .where((doc) => doc['status'] == 'active')
            .map((doc) => _mapOfferData(doc))
            .toList();

        renewedOffers = snapshot.docs
            .where((doc) => doc['status'] == 'renewed')
            .map((doc) => _mapOfferData(doc))
            .toList();

        archivedOffers = snapshot.docs
            .where((doc) => doc['status'] == 'archived')
            .map((doc) => _mapOfferData(doc))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des offres: $e')),
      );
    }
  }

  Map<String, dynamic> _mapOfferData(DocumentSnapshot doc) {
    return {
      'id': doc.id,
      'title': doc['title'] ?? 'Sans titre',
      'type': doc['type'] ?? 'Type inconnu',
      'description': doc['description'] ?? '',
      'monthlyPrice': doc['monthly_price'] ?? '0',
      'yearlyPrice': doc['yearly_price'] ?? '0',
      'coverage': doc['coverage'] ?? {},
      'status': doc['status'] ?? 'active',
      'createdAt': doc['createdAt'] ?? DateTime.now(),
    };
  }

  Future<void> _processOffers() async {
    try {
      final batch = _firestore.batch();

      // Example processing logic - adapt to your business rules
      for (var offer in activeOffers.where((o) => o['daysLeft'] == 0)) {
        final docRef = _offersCollection.doc(offer['id']);
        batch.update(docRef, {'status': 'archived'});
      }

      await batch.commit();
      await _loadOffers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Traitement des offres terminé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du traitement: $e')),
      );
    }
  }

  Future<void> _choosePhoto(String offerId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      setState(() => selectedPhoto = photo.path);

      await _offersCollection.doc(offerId).update({
        'photoPath': photo.path,
        'photoStatus': 'selected',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Map<String, dynamic>>> offerLists = [
      activeOffers,
      renewedOffers,
      [],
      archivedOffers,
    ];

    final List<String> tabTitles = [
      'Offres actives',
      'Offres renouvelées',
      'Envoyer contrat',
      'Offres archivées',
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Gestion des contrats')),
      body: Column(
        children: [
          _buildTabBar(tabTitles, offerLists),
          Divider(height: 1),
          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            _buildOfferList(offerLists[currentTabIndex]),
          if (selectedPhoto != null) _buildPhotoActions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _processOffers,
        child: Icon(Icons.autorenew),
        tooltip: 'Traiter les offres',
      ),
    );
  }

  Widget _buildTabBar(
      List<String> titles, List<List<Map<String, dynamic>>> lists) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => setState(() => currentTabIndex = index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: currentTabIndex == index
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titles[index]),
                  SizedBox(height: 4),
                  if (lists[index].isNotEmpty)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${lists[index].length}',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferList(List<Map<String, dynamic>> offers) {
    if (offers.isEmpty) {
      return Expanded(
        child: Center(child: Text('Aucune offre dans cette catégorie')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer['title'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Type: ${offer['type']}'),
                  Text('Prix mensuel: ${offer['monthlyPrice']}'),
                  Text('Prix annuel: ${offer['yearlyPrice']}'),
                  if (currentTabIndex == 2) // Send contract tab
                    ElevatedButton(
                      onPressed: () => _choosePhoto(offer['id']),
                      child: Text('Ajouter photo'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoActions() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Photo sélectionnée',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Image.file(File(selectedPhoto!), height: 100),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => selectedPhoto = null),
                child: Text('Annuler'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
              ElevatedButton(
                onPressed: () {}, // Implement send functionality
                child: Text('Envoyer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
