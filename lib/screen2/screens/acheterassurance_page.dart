import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FormulaireDemandeAssurance.dart';

class AcheterAssurancePage extends StatefulWidget {
  const AcheterAssurancePage({super.key});

  @override
  State<AcheterAssurancePage> createState() => _AcheterAssurancePageState();
}

class _AcheterAssurancePageState extends State<AcheterAssurancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _offersCollection =
      FirebaseFirestore.instance.collection('insurance_offers');

  // Offres par défaut si Firestore est vide
  final List<Map<String, dynamic>> _defaultOffers = [
    {
      'title': 'Tous Risques',
      'description':
          'La couverture la plus complète pour votre véhicule. Protection contre tous les dommages, vol, incendie, et responsabilité civile.',
      'monthly_price': '4500 DA/mois',
      'yearly_price': '50,000 DA/an (économisez 4,000 DA)',
      'coverage': [
        'Dommages accidentels',
        'Vol total',
        'Incendie',
        'Responsabilité civile illimitée',
        'Assistance 24/7',
        'Véhicule de remplacement'
      ],
      'type': 'Tous Risques',
    },
    {
      'title': 'Tiers Collision',
      'description':
          'Protection pour les dommages à votre véhicule et responsabilité civile en cas d\'accident.',
      'monthly_price': '2500 DA/mois',
      'yearly_price': '28,000 DA/an (économisez 2,000 DA)',
      'coverage': [
        'Dommages collision',
        'Responsabilité civile',
        'Assistance routière',
        'Protection juridique'
      ],
      'type': 'Tiers Collision',
    },
    {
      'title': 'Incendie/Vol',
      'description':
          'Protection spécifique contre les risques d\'incendie et de vol uniquement.',
      'monthly_price': '3000 DA/mois',
      'yearly_price': '33,000 DA/an (économisez 3,000 DA)',
      'coverage': [
        'Vol total',
        'Incendie',
        'Explosion',
        'Catastrophes naturelles'
      ],
      'type': 'Incendie/Vol',
    },
    {
      'title': 'Tiers Simple',
      'description':
          'Couverture minimale obligatoire selon la loi (responsabilité civile uniquement).',
      'monthly_price': '1500 DA/mois',
      'yearly_price': '16,000 DA/an (économisez 2,000 DA)',
      'coverage': [
        'Responsabilité civile',
        'Défense pénale',
        'Recours des tiers'
      ],
      'type': 'Tiers Simple',
    },
  ];

  Future<void> _createDefaultOffers() async {
    try {
      // Vérifier si la collection est vide
      final snapshot = await _offersCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        // Ajouter les offres par défaut
        for (var offer in _defaultOffers) {
          await _offersCollection.add({
            ...offer,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la création des offres par défaut: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _createDefaultOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: const Text(
                'تأمينك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Acheter une assurance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choisissez votre assurance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Comparez nos offres et sélectionnez celle qui vous convient',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildStepperIndicator(1, 5, context),
            const SizedBox(height: 30),
            const Text(
              'Nos offres disponibles:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // StreamBuilder pour afficher les offres depuis Firestore
            StreamBuilder<QuerySnapshot>(
              stream: _offersCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement des offres'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final offers = snapshot.data?.docs ?? [];

                // Si aucune offre dans Firestore, afficher les offres par défaut
                if (offers.isEmpty) {
                  return Column(
                    children: _defaultOffers
                        .map((offer) =>
                            _buildInsuranceCardFromData(context, offer))
                        .toList(),
                  );
                }

                // Afficher les offres depuis Firestore
                return Column(
                  children: offers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildInsuranceCardFromData(context, data);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),
            _buildNextStepsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une carte d'assurance à partir des données
  Widget _buildInsuranceCardFromData(
      BuildContext context, Map<String, dynamic> data) {
    return _buildInsuranceCard(
      context,
      title: data['title'] ?? 'Offre sans nom',
      description: data['description'] ?? 'Description non disponible',
      pricePerMonth: data['monthly_price'] ?? 'Prix non disponible',
      pricePerYear: data['yearly_price'] ?? 'Prix annuel non disponible',
      coverage: List<String>.from(data['coverage'] ?? []),
      icon: _getIconFromType(data['type']),
      color: _getColorFromType(data['type']),
      type: data['type'] ?? 'Autre',
    );
  }

  // Méthodes d'aide pour convertir les types d'offres en icônes/couleurs
  IconData _getIconFromType(String? type) {
    switch (type) {
      case 'Tous Risques':
        return Icons.security;
      case 'Tiers Collision':
        return Icons.car_crash;
      case 'Incendie/Vol':
        return Icons.local_fire_department;
      case 'Tiers Simple':
        return Icons.verified_user;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorFromType(String? type) {
    switch (type) {
      case 'Tous Risques':
        return Colors.green;
      case 'Tiers Collision':
        return Colors.orange;
      case 'Incendie/Vol':
        return Colors.red;
      case 'Tiers Simple':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Les méthodes existantes restent inchangées
  Widget _buildStepperIndicator(
      int currentStep, int totalSteps, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étape $currentStep sur $totalSteps',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildInsuranceCard(
    BuildContext context, {
    required String title,
    required String description,
    required String pricePerMonth,
    required String pricePerYear,
    required List<String> coverage,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          try {
            await _firestore.collection('demandes_assurance').add({
              'typeAssurance': type,
              'timestamp': FieldValue.serverTimestamp(),
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FormulaireDemandeAssurance(typeAssurance: type),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur Firestore: $e')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Couvertures incluses:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...coverage.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pricePerMonth,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          pricePerYear,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await _firestore.collection('demandes_assurance').add({
                          'typeAssurance': type,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormulaireDemandeAssurance(
                              typeAssurance: type,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur Firestore: $e')),
                        );
                      }
                    },
                    child: const Text(
                      'Choisir cette offre',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Étapes pour souscrire:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          _buildStepItem(
            number: 1,
            title: 'Choisir votre type d\'assurance',
            description: 'Sélectionnez l\'offre qui correspond à vos besoins',
          ),
          _buildStepItem(
            number: 2,
            title: 'Remplir le formulaire',
            description: 'Informations personnelles, permis et véhicule',
          ),
          _buildStepItem(
            number: 3,
            title: 'Scanner les documents',
            description: 'CNI, permis, carte grise, CCP et photos du véhicule',
          ),
          _buildStepItem(
            number: 4,
            title: 'Paiement en ligne sécurisé',
            description: 'Paiement direct vers la compagnie d\'assurance',
          ),
          _buildStepItem(
            number: 5,
            title: 'Confirmation et suivi',
            description:
                'Recevez votre contrat et suivez l\'état de votre demande',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
