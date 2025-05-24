import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PageOffres extends StatefulWidget {
  @override
  _PageOffresState createState() => _PageOffresState();
}

class _PageOffresState extends State<PageOffres> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _offersCollection =
      FirebaseFirestore.instance.collection('insurance_offers');

  // Contrôleurs de texte pour l'ajout/modification
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController monthlyPriceController = TextEditingController();
  TextEditingController yearlyPriceController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  List<TextEditingController> coverageControllers = [];
  String? editingDocumentId;

  // Fonction pour afficher le dialogue d'ajout ou modification
  void showOfferDialog({
    String? title,
    String? description,
    String? monthlyPrice,
    String? yearlyPrice,
    String? type,
    List<String>? coverage,
    String? documentId,
  }) {
    titleController.text = title ?? "";
    descriptionController.text = description ?? "";
    monthlyPriceController.text = monthlyPrice ?? "";
    yearlyPriceController.text = yearlyPrice ?? "";
    typeController.text = type ?? "";
    editingDocumentId = documentId;

    // Gérer les couvertures
    coverageControllers.clear();
    if (coverage != null && coverage.isNotEmpty) {
      for (var item in coverage) {
        coverageControllers.add(TextEditingController(text: item));
      }
    } else {
      coverageControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(editingDocumentId == null
              ? "Ajouter une offre"
              : "Modifier l'offre"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Titre de l'offre"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                TextField(
                  controller: monthlyPriceController,
                  decoration: InputDecoration(labelText: "Prix mensuel"),
                ),
                TextField(
                  controller: yearlyPriceController,
                  decoration: InputDecoration(labelText: "Prix annuel"),
                ),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: "Type d'offre"),
                ),
                SizedBox(height: 16),
                Text("Couvertures incluses:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildCoverageFields(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      coverageControllers.add(TextEditingController());
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (editingDocumentId == null) {
                  _addOffer();
                } else {
                  _updateOffer();
                }
                Navigator.pop(context);
              },
              child: Text(editingDocumentId == null ? "Ajouter" : "Modifier"),
            ),
          ],
        );
      },
    );
  }

  // Construire les champs de couverture
  List<Widget> _buildCoverageFields() {
    return coverageControllers.asMap().entries.map((entry) {
      int idx = entry.key;
      TextEditingController controller = entry.value;

      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Couverture ${idx + 1}",
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      coverageControllers.removeAt(idx);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  // Ajouter une offre à Firestore
  Future<void> _addOffer() async {
    try {
      List<String> coverageList = coverageControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      await _offersCollection.add({
        "title": titleController.text,
        "description": descriptionController.text,
        "monthly_price": monthlyPriceController.text,
        "yearly_price": yearlyPriceController.text,
        "type": typeController.text,
        "coverage": coverageList,
        "createdAt": FieldValue.serverTimestamp(),
      });
      _clearControllers();
    } catch (e) {
      print("Erreur lors de l'ajout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout de l'offre")),
      );
    }
  }

  // Mettre à jour une offre dans Firestore
  Future<void> _updateOffer() async {
    try {
      List<String> coverageList = coverageControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      await _offersCollection.doc(editingDocumentId).update({
        "title": titleController.text,
        "description": descriptionController.text,
        "monthly_price": monthlyPriceController.text,
        "yearly_price": yearlyPriceController.text,
        "type": typeController.text,
        "coverage": coverageList,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      _clearControllers();
    } catch (e) {
      print("Erreur lors de la mise à jour: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour de l'offre")),
      );
    }
  }

  // Supprimer une offre de Firestore
  Future<void> _deleteOffer(String documentId) async {
    try {
      await _offersCollection.doc(documentId).delete();
    } catch (e) {
      print("Erreur lors de la suppression: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression de l'offre")),
      );
    }
  }

  // Vider les contrôleurs
  void _clearControllers() {
    titleController.clear();
    descriptionController.clear();
    monthlyPriceController.clear();
    yearlyPriceController.clear();
    typeController.clear();
    coverageControllers.forEach((controller) => controller.dispose());
    coverageControllers.clear();
    editingDocumentId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des offres"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _offersCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final offers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final data = offer.data() as Map<String, dynamic>;
              List<dynamic> coverage = data['coverage'] ?? [];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['description'] ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Prix mensuel: ${data['monthly_price'] ?? ''}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Prix annuel: ${data['yearly_price'] ?? ''}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Type: ${data['type'] ?? ''}",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Couvertures incluses:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...coverage
                          .map((item) => Padding(
                                padding: EdgeInsets.only(left: 16, top: 4),
                                child: Text("• $item"),
                              ))
                          .toList(),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showOfferDialog(
                              title: data['title'],
                              description: data['description'],
                              monthlyPrice: data['monthly_price'],
                              yearlyPrice: data['yearly_price'],
                              type: data['type'],
                              coverage:
                                  List<String>.from(data['coverage'] ?? []),
                              documentId: offer.id,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteOffer(offer.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showOfferDialog(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }
}
