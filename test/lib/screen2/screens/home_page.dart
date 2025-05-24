import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // En-tête
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Navigator.pushNamed(context, '/menu'),
                  ),
                ],
              ),
            ),

            // Liste de services
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildTopCard(
                      context,
                      title: 'S’abonner',
                      description:
                          'Souscrivez à une nouvelle assurance auto rapidement.',
                      icon: Icons.shield_outlined,
                      onTap: () => Navigator.pushNamed(context, '/form-auto'),
                    ),
                    const SizedBox(height: 12),
                    _buildButton(
                      context,
                      title: 'Demande de dépannage',
                      description:
                          'Signalez un problème pour obtenir une aide rapide.',
                      color: Colors.orange,
                      onTap: () =>
                          Navigator.pushNamed(context, '/depannage/home'),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Réclamations',
                      icon: Icons.report,
                      description:
                          'Déclarez un incident lié à votre assurance.',
                      onTap: () =>
                          Navigator.pushNamed(context, '/assurance/claim'),
                    ),
                    _buildMenuItem(
                      context,
                      title: 'Renouvellements',
                      icon: Icons.access_time,
                      description:
                          'Renouvelez facilement votre contrat d’assurance.',
                      onTap: () =>
                          Navigator.pushNamed(context, '/assurance/renewal'),
                    ),
                    _buildMenuItem(
                      context,
                      title: 'Remplir formulaire dépannage',
                      icon: Icons.build,
                      description:
                          'Soumettez une demande de dépannage technique.',
                      onTap: () =>
                          Navigator.pushNamed(context, '/form-depannage'),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Mes documents',
                      description: 'Accéder à vos documents rapidement.',
                      icon: Icons.folder,
                      onTap: () =>
                          Navigator.pushNamed(context, '/mes-fichiers'),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      context,
                      title: 'Notifications',
                      description: 'Voir les dernières alertes et messages.',
                      icon: Icons.notifications_active,
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String title,
      required String description,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.build, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required String title,
      required IconData icon,
      required String description,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
