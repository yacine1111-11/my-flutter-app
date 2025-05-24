import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _extractName(_getEmailFromLogin()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getEmailFromLogin(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ServiceItem(
                    title: 'Assurance',
                    imagePath: 'assets/assurance_icon.png.jpg',
                    onTap: () {
                      Navigator.pushNamed(context, '/assurance');
                    },
                    description: '',
                  ),
                  const SizedBox(height: 30),
                  ServiceItem(
                    title: 'Dépannage',
                    imagePath: 'assets/depanage_icon.png.jpg',
                    onTap: () {
                      Navigator.pushNamed(context, '/depanage');
                    },
                    description: '',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmailFromLogin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user.email!;
    }
    return ''; // Return empty string if no user is logged in
  }

  String _extractName(String email) {
    return email.split('@').first;
  }
}

class ServiceItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final String description;

  const ServiceItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.shade700,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Colors.grey),
                        Text(
                          'Image non trouvée',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
