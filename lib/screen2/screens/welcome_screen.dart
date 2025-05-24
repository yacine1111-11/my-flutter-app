import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../screen/login_screen.dart';
import 'LoginScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Partie supérieure avec le titre
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 2),
                child: const Text(
                  'Bienvenus sur تأمينك',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 45, 46, 46),
                  ),
                ),
              ),
            ),
          ),

          // Photo en bas

          Image.asset(
            'assets/welcome.jpg',
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              height: 200,
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),

          // Conteneur pour les boutons et message
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message en gras à gauche
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Choissez votre service:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                // Boutons services
                Column(
                  children: [
                    _buildServiceButton(
                      context,
                      icon: 'assets/icons/car.svg',
                      title: 'Assurance Auto  et  Assurance dépannage ',
                      subtitle: 'Gérez votre contrat en ligne',
                      color: const Color(0xFF2E86AB),
                      onPressed: () =>
                          _navigateToLogin1(context, '/assurance/home'),
                    ),
                    const SizedBox(height: 16),
                    _buildServiceButton(
                      context,
                      icon: 'assets/icons/tools.svg',
                      title: 'Dépannage',
                      subtitle: 'Gérez votre travail en ligne',
                      color: const Color(0xFFF18F01),
                      onPressed: () =>
                          _navigateToLogin2(context, '/depannage/home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  void _navigateToLogin1(BuildContext context, String serviceType) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _navigateToLogin2(BuildContext context, String serviceType) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen2(),
      ),
    );
  }
}
