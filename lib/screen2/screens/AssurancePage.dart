import 'package:flutter/material.dart';

class AssurancePage extends StatelessWidget {
  const AssurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Services d\'Assurance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildServiceCard(
              context,
              icon: Icons.shopping_cart,
              title: "Abonner ",
              description:
                  "Souscrivez à une nouvelle assurance auto ou habitation",
              color: Colors.green.shade700,
              route: '/acheter-assurance',
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              context,
              icon: Icons.autorenew,
              title: "Renouveler mon assurance",
              description: "Prolongez votre contrat d'assurance actuel",
              color: Colors.orange.shade700,
              route: '/renouveller',
            ),
            const SizedBox(height: 16),
            _buildServiceCard(
              context,
              icon: Icons.car_crash,
              title: "Déclarer un accident",
              description:
                  "Signalez un sinistre et démarrez la procédure d'indemnisation",
              color: Colors.blue.shade700,
              route: '/reclamer-accident',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
