import 'package:flutter/material.dart';
import 'map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeDemandes extends StatelessWidget {
  // Fonction pour accepter une demande
  Future<void> _accepterDemande(BuildContext context, String demandeId,
      Map<String, dynamic> demandeData) async {
    try {
      // Ajouter une notification d'acceptation
      await FirebaseFirestore.instance.collection('notifications').add({
        'demandeId': demandeId,
        'clientId': demandeData['userId'],
        'status': 'acceptée',
        'message': 'Votre demande a été acceptée par un mécanicien',
        'timestamp': FieldValue.serverTimestamp(),
        'probleme': demandeData['probleme'],
        'nomMecanicien': 'Nom du mécanicien', // À remplacer par le nom réel
      });

      // Mettre à jour le statut de la demande
      await FirebaseFirestore.instance
          .collection('demandes')
          .doc(demandeId)
          .update({
        'status': 'acceptée',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande acceptée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  // Fonction pour refuser une demande
  Future<void> _refuserDemande(BuildContext context, String demandeId,
      Map<String, dynamic> demandeData) async {
    try {
      // Ajouter une notification de refus
      await FirebaseFirestore.instance.collection('notifications').add({
        'demandeId': demandeId,
        'clientId': demandeData['userId'],
        'status': 'refusée',
        'message': 'Votre demande a été refusée par un mécanicien',
        'timestamp': FieldValue.serverTimestamp(),
        'probleme': demandeData['probleme'],
        'nomMecanicien': 'Nom du mécanicien', // À remplacer par le nom réel
      });

      // Mettre à jour le statut de la demande
      await FirebaseFirestore.instance
          .collection('demandes')
          .doc(demandeId)
          .update({
        'status': 'refusée',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande refusée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📋 Liste des demandes"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('demandes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("Aucune demande trouvée."));
            }

            final demandes = snapshot.data!.docs;

            return ListView.builder(
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final doc = demandes[index];
                final data = doc.data() as Map<String, dynamic>;
                final demandeId = doc.id;
                final status = data['status'] ?? 'en attente';
                final isAccepted = status == 'acceptée';
                final isRejected = status == 'refusée';
                final isProcessed = isAccepted || isRejected;

                // Choix d'icône & couleur en fonction du problème
                IconData icon = Icons.build;
                Color color = Colors.blue;
                String probleme = data['probleme'] ?? '';

                if (probleme.contains("batterie")) {
                  icon = Icons.car_repair;
                  color = Colors.blue;
                } else if (probleme.contains("pneu")) {
                  icon = Icons.tire_repair;
                  color = Colors.red;
                } else if (probleme.contains("clé")) {
                  icon = Icons.vpn_key;
                  color = Colors.green;
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(
                          data["nom"] ?? "Nom inconnu",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "🛠️ Probleme :${data["probleme"] ?? "Inconnu"}"),
                            Text(
                                "🚗 Type de voiture : ${data["typeVoiture"] ?? "-"}"),
                            Text(
                                "🎨 Couleur : ${data["couleurVoiture"] ?? "-"}"),
                            Text("📍 adresse :${data["adresse"] ?? "-"}"),
                            Text("📍 telephone :${data["telephone"] ?? "-"}"),
                            if (isProcessed)
                              Text(
                                "Statut: ${isAccepted ? 'Acceptée' : 'Refusée'}",
                                style: TextStyle(
                                  color: isAccepted ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.grey, size: 18),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/map',
                            arguments: ClientLocation(
                              (data["x"] ?? 0).toDouble(),
                              (data["y"] ?? 0).toDouble(),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.check, color: Colors.white),
                              label: Text('Accepter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isProcessed ? Colors.grey : Colors.green,
                              ),
                              onPressed: isProcessed
                                  ? null
                                  : () => _accepterDemande(
                                      context, demandeId, data),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.close, color: Colors.white),
                              label: Text('Refuser'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isProcessed ? Colors.grey : Colors.red,
                              ),
                              onPressed: isProcessed
                                  ? null
                                  : () =>
                                      _refuserDemande(context, demandeId, data),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
