import 'package:flutter/material.dart';

class DemandeAccident {
  final String id;
  final String conducteur1Nom;
  final String conducteur1Telephone;
  final String? conducteur2Nom;
  final String? conducteur2Telephone;
  final String modeleVoiture;
  final String plaqueImmatriculation;
  final String lieuAccident;
  final String dateAccident;
  final String descriptionAccident;
  final List<Map<String, String>> imagesAccident;
  final List<Map<String, String>> permisConduire;
  final List<Map<String, String>> carteIdentite;
  final DateTime dateSoumission;

  DemandeAccident({
    required this.id,
    required this.conducteur1Nom,
    required this.conducteur1Telephone,
    this.conducteur2Nom,
    this.conducteur2Telephone,
    required this.modeleVoiture,
    required this.plaqueImmatriculation,
    required this.lieuAccident,
    required this.dateAccident,
    required this.descriptionAccident,
    required this.imagesAccident,
    required this.permisConduire,
    required this.carteIdentite,
    required this.dateSoumission,
  });
}

class Request {
  final String id;
  final DemandeAccident reclamation;
  final String status; // "accepté" ou "refusé"
  final String rejectionReason;

  Request({
    required this.id,
    required this.reclamation,
    required this.status,
    required this.rejectionReason,
  });
}

class Reclamation extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<Reclamation> {
  final List<Request> requests = [
    Request(
      id: '#1',
      reclamation: DemandeAccident(
        id: '2',
        conducteur1Nom: 'Salem Ali',
        conducteur1Telephone: '0587654321',
        modeleVoiture: 'Nissan Sunny 2018',
        plaqueImmatriculation: 'DEF 5678',
        lieuAccident: 'Rue Tahliya - Devant le restaurant français',
        dateAccident: '15/10/2023 10:15',
        descriptionAccident: 'Rayure sur le côté droit en reculant',
        imagesAccident: [
          {'imageUrl': 'https://via.placeholder.com/150'},
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        permisConduire: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        carteIdentite: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        dateSoumission: DateTime.now().subtract(const Duration(hours: 5)),
        conducteur2Nom: 'sihame',
        conducteur2Telephone: '0987986534',
      ),
      status: 'accepté',
      rejectionReason: '',
    ),
    Request(
      id: '#2',
      reclamation: DemandeAccident(
        id: '2',
        conducteur1Nom: 'hanane ahmed',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 5)),
        conducteur1Telephone: '0587654321',
        modeleVoiture: 'Nissan Sunny 2018',
        plaqueImmatriculation: 'DEF 5678',
        lieuAccident: 'Rue Tahliya - Devant le restaurant français',
        dateAccident: '15/10/2023 10:15',
        descriptionAccident: 'Rayure sur le côté droit en reculant',
        imagesAccident: [
          {'imageUrl': 'https://via.placeholder.com/150'},
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        permisConduire: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        carteIdentite: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        conducteur2Nom: 'meriam',
        conducteur2Telephone: '1234098756',
      ),
      status: 'accepté',
      rejectionReason: '',
    ),
    Request(
      id: '#2',
      reclamation: DemandeAccident(
        id: '2',
        conducteur1Nom: 'hanane amel',
        dateSoumission: DateTime.now().subtract(const Duration(hours: 5)),
        conducteur1Telephone: '0587654321',
        modeleVoiture: 'Nissan Sunny 2018',
        plaqueImmatriculation: 'DEF 5678',
        lieuAccident: 'Rue Tahliya - Devant le restaurant français',
        dateAccident: '15/10/2023 10:15',
        descriptionAccident: 'Rayure sur le côté droit en reculant',
        imagesAccident: [
          {'imageUrl': 'https://via.placeholder.com/150'},
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        permisConduire: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
        carteIdentite: [
          {'imageUrl': 'https://via.placeholder.com/150'},
        ],
      ),
      status: 'refusé',
      rejectionReason: 'permis invalide',
    ),
  ];
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'accepté'; // "accepté" ou "refusé"

  @override
  Widget build(BuildContext context) {
    List<Request> filteredRequests = requests.where((req) {
      return (_filterStatus.isEmpty || req.status == _filterStatus) &&
          (req.reclamation.conducteur1Nom
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()));
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par nom',
                border: OutlineInputBorder(),
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                iconColor: Colors.blue,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton "Accepté" avec un style modernisé
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _filterStatus = 'accepté'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Stack(
                    clipBehavior:
                        Clip.none, // Ensures the badge doesn't get clipped
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Accepté',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Add Badge for Count
                      Positioned(
                        top: 0, // Position the badge slightly above the icon
                        right: 150, // Position it to the top-right
                        child: CircleAvatar(
                          radius: 10, // Size of the badge
                          backgroundColor:
                              Colors.green, // Background color for the badge
                          child: Text(
                            requests
                                .where((req) => req.status == 'accepté')
                                .length
                                .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10), // Espacement entre les boutons

              // Bouton "Refusé" avec un style modernisé
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _filterStatus = 'refusé'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Stack(
                    clipBehavior:
                        Clip.none, // Ensures the badge doesn't get clipped
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.red, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Refusé',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Add Badge for Count
                      Positioned(
                        top: 0, // Position the badge slightly above the icon
                        right: 150, // Position it to the top-right
                        child: CircleAvatar(
                          radius: 10, // Size of the badge
                          backgroundColor:
                              Colors.red, // Background color for the badge
                          child: Text(
                            requests
                                .where((req) => req.status == 'refusé')
                                .length
                                .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          filteredRequests.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      'Aucun résultat trouvé',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final req = filteredRequests[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        child: ListTile(
                          title: Text(req.reclamation.conducteur1Nom,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Icon(
                              req.status == 'accepté'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: req.status == 'accepté'
                                  ? Colors.green
                                  : Colors.red),
                          onTap: () => _showRequestDetailse(context, req),
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

void _showRequestDetailse(BuildContext context, Request req) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Détails de la Demande ${req.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Informations :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Conducteur 1: ${req.reclamation.conducteur1Nom}'),
              Text('Téléphone: ${req.reclamation.conducteur1Telephone}'),
              Text('Conducteur 2:${req.reclamation.conducteur2Nom}'),
              Text('Téléphone 2: ${req.reclamation.conducteur2Telephone}'),
              Text('Modèle voiture:${req.reclamation.modeleVoiture}'),
              Text(
                  'Plaque d\'immatriculation:${req.reclamation.plaqueImmatriculation}'),
              Text('Lieu de l\'accident:${req.reclamation.lieuAccident}'),
              Text('Date de l\'accident:${req.reclamation.dateAccident}'),
              Text('Description:${req.reclamation.descriptionAccident}'),
              const Text('Photos de la vehicule:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (var photo in req.reclamation.imagesAccident)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(photo['imageUrl']!, height: 100),
                    const SizedBox(height: 10),
                  ],
                ),
              const Divider(),
              const Text('Photos de permis:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (var photo in req.reclamation.permisConduire)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(photo['imageUrl']!, height: 100),
                    const SizedBox(height: 10),
                  ],
                ),
              const Text('Photos de carte identite:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              for (var photo in req.reclamation.carteIdentite)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(photo['imageUrl']!, height: 100),
                    const SizedBox(height: 10),
                  ],
                ),
              const Divider(),
              const SizedBox(height: 10),
              Text('Statut: ${req.status}',
                  style: TextStyle(
                      color:
                          req.status == "accepté" ? Colors.green : Colors.red)),
              if (req.status == "refusé")
                Text('Raison du Refus: ${req.rejectionReason}',
                    style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fermer'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
