import 'package:flutter/material.dart';

class MesFichiersPage extends StatelessWidget {
  const MesFichiersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mes Fichiers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          // Galerie d'images
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 10,
            children: [
              _buildClickableImage(context, 'contrat.png'),

              // Ajouter d'autres images ici
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour image cliquable avec gestion d'erreur
  Widget _buildClickableImage(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context, imagePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImageWithErrorHandling(imagePath),
      ),
    );
  }

  // Widget pour gérer les erreurs de chargement d'image
  Widget _buildImageWithErrorHandling(String imagePath) {
    return Image.asset(
      imagePath,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child:
                Text('Image non trouvée', style: TextStyle(color: Colors.red)),
          ),
        );
      },
      fit: BoxFit.cover,
    );
  }

  // Fonction pour afficher l'image en plein écran
  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: _buildImageWithErrorHandling(imagePath),
            ),
          ),
        ),
      ),
    );
  }
}
