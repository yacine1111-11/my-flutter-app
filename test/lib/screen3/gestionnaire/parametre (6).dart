import 'package:flutter/material.dart';

import '../login.dart';

class AdminSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Configuration du Système
            _buildSettingsTile(
              title: 'Le Profil',
              icon: Icons.person,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Données initiales pour le profil
                    String systemName =
                        'Nom du Compagnie'; // Exemple par défaut
                    String email = 'example@email.com'; // Exemple par défaut
                    String phoneNumber = '0123456789'; // Exemple par défaut
                    String location = 'Alger'; // Exemple par défaut

                    return AlertDialog(
                      title: const Text('Profil Utilisateur'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Affichage du nom
                            Row(
                              children: [
                                const Text(
                                  'Nom du Compagnie : ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(systemName),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Affichage de l'email
                            Row(
                              children: [
                                const Text(
                                  'Adresse Email : ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(email),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Affichage du numéro de téléphone
                            Row(
                              children: [
                                const Text(
                                  'Numéro de Téléphone : ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(phoneNumber),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Affichage du lieu
                            Row(
                              children: [
                                const Text(
                                  'Lieu : ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(location),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        // Bouton pour fermer la boîte de dialogue
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fermer'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            _buildSettingsTile(
              title: 'Langue',
              icon: Icons.language,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String selectedLanguage = 'Français'; // Langue par défaut

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Modifier la Langue'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: selectedLanguage,
                                  items: ['Français', 'Anglais', 'Espagnol']
                                      .map((language) =>
                                          DropdownMenuItem<String>(
                                            value: language,
                                            child: Text(language),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLanguage = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                print(
                                    'Langue sélectionnée : $selectedLanguage');
                                Navigator.of(context).pop();
                              },
                              child: const Text('Sauvegarder'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            _buildSettingsTile(
              title: 'Mode',
              icon: Icons.brightness_4,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String selectedMode = 'Clair'; // Mode par défaut

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Modifier le Mode'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: selectedMode,
                                  items: ['Clair', 'Sombre']
                                      .map((mode) => DropdownMenuItem<String>(
                                            value: mode,
                                            child: Text(mode),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMode = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                print('Mode sélectionné : $selectedMode');
                                Navigator.of(context).pop();
                              },
                              child: const Text('Sauvegarder'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 10,
            ),

            _buildSettingsTile(
              title: 'Déconnexion',
              icon: Icons.logout,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Logic to navigate back to Login screen
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('Confirmer'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Titre de Section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  // Widget: Paramètre individuel
  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Exemple de page de liste d'utilisateurs
class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Utilisateurs')),
      body: const Center(child: Text('Page des utilisateurs')),
    );
  }
}

// Exemple de page de connexion
