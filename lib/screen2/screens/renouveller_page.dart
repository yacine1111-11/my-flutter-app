import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'FormulaireRenouvellement.dart';

class RenouvellerPage extends StatefulWidget {
  const RenouvellerPage({super.key});

  @override
  State<RenouvellerPage> createState() => _RenouvellerPageState();
}

class _RenouvellerPageState extends State<RenouvellerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> eligibleContracts = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEligibleContracts();
  }

  Future<void> _fetchEligibleContracts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Utilisateur non connecté';
        });
        return;
      }

      final querySnapshot = await _firestore
          .collection('insurance_offers')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Filtrer les contrats éligibles (expirant dans les 30 jours ou déjà expirés)
      final now = DateTime.now();
      final thresholdDate = now.add(const Duration(days: 30));

      setState(() {
        eligibleContracts = querySnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final expirationDate =
                  (data['expirationDate'] as Timestamp?)?.toDate();
              final isExpired = expirationDate?.isBefore(now) ?? false;
              final expiresSoon =
                  expirationDate?.isBefore(thresholdDate) ?? false;

              return {
                ...data,
                'id': doc.id,
                'isEligible': isExpired || expiresSoon,
                'expirationDate': expirationDate,
              };
            })
            .where((contract) => contract['isEligible'] == true)
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
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
              'Renouveler assurance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Renouvelez votre assurance',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Vos informations client seront pré-remplies pour faciliter le processus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildStepperIndicator(1, 4, context),
                      const SizedBox(height: 30),
                      const Text(
                        'Vos contrats éligibles au renouvellement:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (eligibleContracts.isEmpty)
                        _buildNoContractsCard()
                      else
                        ...eligibleContracts.map((contract) {
                          return Column(
                            children: [
                              _buildContractCard(
                                context,
                                contract: contract,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormulaireRenouvellement(
                                        contractId: contract['id'],
                                        contractNumber:
                                            contract['contractNumber'] ?? 'N/A',
                                        typeAssurance:
                                            contract['type'] ?? 'Type inconnu',
                                        currentPrice:
                                            contract['yearly_price'] ??
                                                '33,000 DA/an',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      _buildNextStepsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoContractsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.assignment_outlined, size: 50, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              'Aucun contrat éligible au renouvellement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vous n\'avez pas de contrats arrivant à expiration ou vos contrats ne sont pas encore éligibles au renouvellement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchEligibleContracts,
              child: const Text('Actualiser la liste'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context, {
    required Map<String, dynamic> contract,
    required VoidCallback onTap,
  }) {
    final expirationDate = contract['expirationDate'] as DateTime?;
    final isExpired = expirationDate?.isBefore(DateTime.now()) ?? false;
    final formattedDate = expirationDate != null
        ? DateFormat('dd/MM/yyyy').format(expirationDate)
        : 'Date inconnue';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Offre: ${contract['title'] ?? 'Sans titre'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isExpired
                          ? 'Expiré le $formattedDate'
                          : 'Expire le $formattedDate',
                      style: TextStyle(
                        color: isExpired ? Colors.red[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildContractDetail(
                  'Type d\'assurance', contract['type'] ?? 'Non spécifié'),
              _buildContractDetail('Description',
                  contract['description'] ?? 'Aucune description'),
              _buildContractDetail('Prix annuel',
                  contract['yearly_price'] ?? 'Prix non disponible'),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onTap,
                  child: const Text(
                    'Renouveler cette offre',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildContractDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
            'Processus de renouvellement:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),
          _buildStepItem(
            number: 1,
            title: 'Sélectionner le contrat à renouveler',
            description: 'Choisissez parmi vos contrats éligibles',
          ),
          _buildStepItem(
            number: 2,
            title: 'Vérifier les informations',
            description: 'Vos données personnelles seront pré-remplies',
          ),
          _buildStepItem(
            number: 3,
            title: 'Mettre à jour les documents',
            description: 'Scanner les nouveaux documents si nécessaire',
          ),
          _buildStepItem(
            number: 4,
            title: 'Paiement en ligne sécurisé',
            description: 'Paiement direct vers la compagnie d\'assurance',
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
