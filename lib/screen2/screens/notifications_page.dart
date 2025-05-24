import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsStream = _firestore
        .collection('demandes_assurance')
        .where('email', isEqualTo: _auth.currentUser?.email)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(child: Text('Aucune notification'));
          }

          // Filter and sort locally
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['statut'] == 'Accepté' || data['statut'] == 'Refusé';
          }).toList()
            ..sort((a, b) {
              final aDate = (a.data() as Map<String, dynamic>)['timestamp'];
              final bDate = (b.data() as Map<String, dynamic>)['timestamp'];
              return bDate.compareTo(aDate); // Sort by timestamp descending
            });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: filteredDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['statut'];
              final vehicleInfo =
                  '${data['marqueVehicule']} ${data['modeleVehicule']}';
              final timestamp = data['timestamp']?.toDate() ?? DateTime.now();
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vehicleInfo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: status == 'Accepté'
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: status == 'Accepté'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              status == 'Accepté' ? 'Acceptée' : 'Refusée',
                              style: TextStyle(
                                color: status == 'Accepté'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Date: $formattedDate'),
                      if (data['adminComment'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Commentaire: ${data['adminComment']}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text('Type: ${data['typeAssurance']}'),
                      Text('Immatriculation: ${data['matriculation']}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
