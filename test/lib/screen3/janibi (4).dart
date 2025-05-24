import 'package:flutter/material.dart';

import '../listreclamation (3).dart';
import '../reclamation (7).dart';
import 'agent/listassu (2).dart';
import 'gestionnaire/parametre (6).dart';

class DashboardScreeneee extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreeneee> {
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
                  title: " Les reclamation ",
                  page: 'insurance_requests',
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
        return IncidentsScreen();
      case 'insurance':
        return RequestListPage();
      case 'reclamation':
        return Reclamation();
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
  final List<String> demandes = ['Ali', 'Zara', 'Ahmed', 'Fatima', 'Khalid'];
  final List<String> demandesAcceptees = [];
  final List<String> demandesRefusees = [];
  String searchQueryAcceptees = '';
  String searchQueryRefusees = '';
  List<String> filteredAcceptees = [];
  List<String> filteredRefusees = [];

  @override
  void initState() {
    super.initState();
    filteredAcceptees = List.from(demandesAcceptees);
    filteredRefusees = List.from(demandesRefusees);
  }

  void acceptRequest(String demande) {
    setState(() {
      demandesAcceptees.add(demande);
      demandesAcceptees.sort(); // Tri alphabétique
      filteredAcceptees = List.from(demandesAcceptees);
      demandes.remove(demande);
    });
  }

  void refuseRequest(String demande) {
    setState(() {
      demandesRefusees.add(demande);
      filteredRefusees = List.from(demandesRefusees);
      demandes.remove(demande);
    });
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
