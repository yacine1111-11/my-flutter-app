import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agent/demandeassurance (2).dart';
import 'agent/listassu (2).dart';
import 'agent/listdep (2).dart';
import 'agent/parametre (5).dart';
import 'demandedeppanage.dart';

class DashboardScreenee extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreenee> {
  String _currentPage =
      'insurance_requests'; // Suivi de la page actuellement affichée

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Static for Desktop)
          Container(
            width: 250,
            color: Colors.blue.shade100,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 20,
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    'تأمينك',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                SizedBox(height: 15),
                _buildSidebarItem(
                  icon: Icons.verified_user,
                  title: "Demandes d'assurances",
                  page: 'insurance_requests',
                ),
                _buildSidebarItem(
                  icon: Icons.car_repair,
                  title: "Demandes de depannage ",
                  page: 'withdraw_requests',
                ),
                _buildSidebarItem(
                  icon: Icons.policy,
                  title: "List d'assurances",
                  page: 'insurance_list',
                ),
                _buildSidebarItem(
                  icon: Icons.settings,
                  title: "Paramètres ",
                  page: 'settings',
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // Génération d'un élément du sidebar
  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String page,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            _currentPage == page ? Colors.black : Colors.blue, // Change couleur
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _currentPage == page
              ? Colors.blue
              : Colors.black, // Change couleur du texte
          fontWeight: _currentPage == page
              ? FontWeight.bold
              : FontWeight.normal, // Gras pour la page active
        ),
      ),
      tileColor: _currentPage == page
          ? Colors.blue
          : const Color.fromARGB(255, 54, 36, 36), // Change le fond
      onTap: () {
        setState(() {
          _currentPage = page; // Met à jour la page actuellement sélectionnée
        });
      },
    );
  }

  // Génération du contenu principal en fonction de la page actuelle
  Widget _buildMainContent() {
    switch (_currentPage) {
      case 'insurance_requests':
        return DemandesAssuranceScreen();
      case 'withdraw_requests':
        return ServiceProvidersScreen();

      case 'insurance_list':
        return RequestListPage();
      case 'withdraw_list':
        return Deppanagelist();
      case 'settings':
        return AdminSettingsPage();
      default:
        return Center(
            child: Text('Page introuvable', style: TextStyle(fontSize: 20)));
    }
  }
}

class ListWithSearchPage extends StatefulWidget {
  const ListWithSearchPage({super.key});

  @override
  _ListWithSearchPageState createState() => _ListWithSearchPageState();
}

class _ListWithSearchPageState extends State<ListWithSearchPage> {
  List<String> demandes = [];
  List<String> demandesAcceptees = [];
  List<String> demandesRefusees = [];
  List<String> filteredAcceptees = [];
  List<String> filteredRefusees = [];
  String searchQueryAcceptees = '';
  String searchQueryRefusees = '';

  @override
  void initState() {
    super.initState();
    _loadDemandesDepuisFirestore();
  }

  Future<void> _loadDemandesDepuisFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('demandes_assurance').get();
    final loadedDemandes =
        snapshot.docs.map((doc) => doc['nom'] as String).toList();

    setState(() {
      demandes = loadedDemandes;
    });
  }

  void acceptRequest(String demande) async {
    setState(() {
      demandesAcceptees.add(demande);
      demandesAcceptees.sort();
      filteredAcceptees = List.from(demandesAcceptees);
      demandes.remove(demande);
    });

    // Mettre à jour le statut dans Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('demandes_assurance')
        .where('nom', isEqualTo: demande)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'statut': 'acceptée'});
    }
  }

  void refuseRequest(String demande) async {
    setState(() {
      demandesRefusees.add(demande);
      filteredRefusees = List.from(demandesRefusees);
      demandes.remove(demande);
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('demandes_assurance')
        .where('nom', isEqualTo: demande)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'statut': 'refusée'});
    }
  }

  void searchInAcceptees(String query) {
    setState(() {
      searchQueryAcceptees = query;
      filteredAcceptees = demandesAcceptees
          .where((item) =>
              item.toLowerCase().contains(searchQueryAcceptees.toLowerCase()))
          .toList();
    });
  }

  void searchInRefusees(String query) {
    setState(() {
      searchQueryRefusees = query;
      filteredRefusees = demandesRefusees
          .where((item) =>
              item.toLowerCase().contains(searchQueryRefusees.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listes avec Recherche'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choix des demandes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                return ListTile(
                  title: Text(demande),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => acceptRequest(demande),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accepter'),
                      ),
                      ElevatedButton(
                        onPressed: () => refuseRequest(demande),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Refuser'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Text(
            'Demandes Acceptées',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: searchInAcceptees,
              decoration: InputDecoration(
                labelText: 'Rechercher dans Acceptées',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAcceptees.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(filteredAcceptees[index]));
              },
            ),
          ),
          const Divider(),
          const Text(
            'Demandes Refusées',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: searchInRefusees,
              decoration: InputDecoration(
                labelText: 'Rechercher dans Refusées',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRefusees.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(filteredRefusees[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
