import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screen3/demandedeppanage.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _animate = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _animate = false);
      }
    });
  }

  // Modification: Suppression du orderBy et where pour éviter l'index
  Stream<QuerySnapshot> _getDemandesStream() {
    return _firestore.collection('demandes').snapshots();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('demandes').get();
      setState(() => _errorMessage = null);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur de chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            AnimatedSlide(
              offset: _animate ? Offset(0, -0.5) : Offset(0, 0),
              duration: Duration(seconds: 2),
              curve: Curves.easeOut,
              child: Icon(Icons.notifications, size: 28, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getDemandesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune demande disponible'));
          }

          // Modification: Filtrage local au lieu de la requête Firestore
          final demandes = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DemandeDepannage(
                  id: doc.id,
                  nomComplet: data['nom'] ?? 'Non spécifié',
                  adresse: data['adresse'] ?? 'Adresse inconnue',
                  telephone: data['telephone'] ?? '',
                  typeVoiture: data['typeVoiture'] ?? '',
                  couleurVoiture: data['couleurVoiture'] ?? '',
                  probleme: data['problème'] ?? 'Problème non spécifié',
                  date:
                      (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  position: GeoPoint(
                    data['x'] ?? 0,
                    data['y'] ?? 0,
                  ),
                  status: data['status'] ?? 'Inconnu',
                );
              })
              .where(
                  (demande) => demande.status == 'En attente') // Filtrage local
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Tri local

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        child: Text(
                          "Taminik",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: AnimatedOpacity(
                          opacity: _animate ? 1.0 : 0.0,
                          duration: Duration(seconds: 2),
                          child: Icon(Icons.notifications_active,
                              color: Colors.red, size: 30),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Vos notifications (${demandes.length})",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: demandes.isEmpty
                        ? Center(child: Text('Aucune demande en attente'))
                        : ListView.builder(
                            itemCount: demandes.length,
                            itemBuilder: (context, index) {
                              final demande = demandes[index];
                              final formattedDate =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(demande.date);

                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.car_repair,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    "Demande de ${demande.nomComplet}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Problème: ${demande.probleme}"),
                                      Text("Adresse: ${demande.adresse}"),
                                      Text("Date: $formattedDate"),
                                    ],
                                  ),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ServiceProvidersScreen(),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
}

class DemandeDepannage {
  final String id;
  final String nomComplet;
  final String adresse;
  final String telephone;
  final String typeVoiture;
  final String couleurVoiture;
  final String probleme;
  final DateTime date;
  final GeoPoint position;
  final String status;

  DemandeDepannage({
    required this.id,
    required this.nomComplet,
    required this.adresse,
    required this.telephone,
    required this.typeVoiture,
    required this.couleurVoiture,
    required this.probleme,
    required this.date,
    required this.position,
    required this.status,
  });
}
