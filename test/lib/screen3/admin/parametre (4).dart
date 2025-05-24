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
            // Section Configuration du Système
            _buildSectionTitle('Configuration du Système'),
            _buildSettingsTile(
              title: 'Modifier le Profile ',
              icon: Icons.settings,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String systemName = '';
                    String email = '';
                    String phoneNumber = '';
                    String location = '';
                    String errorMessage = '';

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Modifier les Détails'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nom du Compagnie
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Nom du Compagnie',
                                  ),
                                  onChanged: (value) {
                                    systemName = value;
                                    setState(() {
                                      errorMessage =
                                          ''; // Réinitialiser les erreurs
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Adresse Email
                                TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Adresse Email',
                                  ),
                                  onChanged: (value) {
                                    email = value;
                                    setState(() {
                                      errorMessage =
                                          ''; // Réinitialiser les erreurs
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Numéro de Téléphone
                                TextField(
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Numéro de Téléphone',
                                  ),
                                  onChanged: (value) {
                                    phoneNumber = value;
                                    setState(() {
                                      errorMessage =
                                          ''; // Réinitialiser les erreurs
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Lieu
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Lieu',
                                  ),
                                  onChanged: (value) {
                                    location = value;
                                    setState(() {
                                      errorMessage =
                                          ''; // Réinitialiser les erreurs
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Message d'erreur
                                if (errorMessage.isNotEmpty)
                                  Text(
                                    errorMessage,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
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
                                // VALIDATIONS
                                if (systemName.isEmpty ||
                                    email.isEmpty ||
                                    phoneNumber.isEmpty ||
                                    location.isEmpty) {
                                  setState(() {
                                    errorMessage =
                                        'Tous les champs doivent être remplis.';
                                  });
                                  return;
                                }

                                // Valider le nom : pas de chiffres
                                if (!RegExp(r'^[a-zA-Z\s]+$')
                                    .hasMatch(systemName)) {
                                  setState(() {
                                    errorMessage =
                                        'Le nom ne doit contenir que des lettres.';
                                  });
                                  return;
                                }

                                // Valider l'email : format correct
                                if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(email)) {
                                  setState(() {
                                    errorMessage =
                                        'L\'adresse email n\'est pas valide.';
                                  });
                                  return;
                                }

                                // Valider le numéro de téléphone : 10 chiffres
                                if (!RegExp(r'^\d{10}$')
                                    .hasMatch(phoneNumber)) {
                                  setState(() {
                                    errorMessage =
                                        'Le numéro de téléphone doit contenir exactement 10 chiffres.';
                                  });
                                  return;
                                }

                                // Afficher les données valides
                                print('Nom du système : $systemName');
                                print('Email : $email');
                                print('Numéro de téléphone : $phoneNumber');
                                print('Lieu : $location');
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

            const SizedBox(height: 16),

            // Section Sécurité
            _buildSectionTitle('Sécurité'),
            _buildSettingsTile(
              title: 'Modifier le Mot de Passe Admin',
              icon: Icons.lock,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String newPassword = '';
                    String confirmPassword = '';
                    String errorMessage = '';
                    bool isPasswordVisible =
                        false; // État pour le champ "Nouveau mot de passe"
                    bool isConfirmPasswordVisible =
                        false; // État pour le champ "Confirmer le mot de passe"

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Modifier le Mot de Passe Admin'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Nouveau Mot de Passe',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible =
                                            !isPasswordVisible; // Basculer l'état
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    newPassword = value;
                                    errorMessage =
                                        ''; // Réinitialiser le message d'erreur
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                obscureText: !isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirmer le Mot de Passe',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible; // Basculer l'état
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    confirmPassword = value;
                                    errorMessage =
                                        ''; // Réinitialiser le message d'erreur
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              if (errorMessage.isNotEmpty)
                                Text(
                                  errorMessage,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (newPassword.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  setState(() {
                                    errorMessage =
                                        'Veuillez remplir les deux champs.';
                                  });
                                  return;
                                }
                                if (newPassword.length < 6) {
                                  setState(() {
                                    errorMessage =
                                        'Le mot de passe doit contenir au moins 6 caractères.';
                                  });
                                  return;
                                }
                                if (newPassword != confirmPassword) {
                                  setState(() {
                                    errorMessage =
                                        'Les mots de passe ne correspondent pas.';
                                  });
                                  return;
                                }
                                print('Mot de passe admin modifié.');
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
            const SizedBox(height: 16),

            // Section Déconnexion
            _buildSectionTitle('Session'),
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
