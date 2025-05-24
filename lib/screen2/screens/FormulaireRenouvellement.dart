import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RenewalFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit renewal application
  static Future<String> submitRenewal({
    required String userId,
    required String contractId,
    required String contractNumber,
    required String insuranceType,
    required Map<String, dynamic> personalInfo,
    required List<File> documents,
    required double amount,
  }) async {
    try {
      // Upload documents first
      final documentUrls = await Future.wait([
        _uploadDocument(documents[0], 'carte_grise_$contractNumber'),
        _uploadDocument(documents[1], 'permis_$contractNumber'),
        _uploadDocument(documents[2], 'ccp_$contractNumber'),
      ]);

      // Upload vehicle images
      final vehicleImageUrls = await Future.wait(documents
          .sublist(3)
          .map((file) => _uploadDocument(
              file, 'vehicle_${DateTime.now().millisecondsSinceEpoch}'))
          .toList());

      // Create renewal record
      final docRef = await _firestore.collection('insurance_renewals').add({
        'userId': userId,
        'contractId': contractId,
        'contractNumber': contractNumber,
        'type': insuranceType,
        'personalInfo': personalInfo,
        'documents': {
          'carteGrise': documentUrls[0],
          'permis': documentUrls[1],
          'ccp': documentUrls[2],
          'vehiclePhotos': vehicleImageUrls,
        },
        'amount': amount,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'processedAt': null,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Renewal submission failed: $e');
    }
  }

  // Helper method for document uploads
  static Future<String> _uploadDocument(File file, String path) async {
    try {
      final ref = _storage.ref().child('renewal_documents/$path');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Document upload failed: $e');
    }
  }

  // Check renewal status
  static Stream<DocumentSnapshot> getRenewalStatus(String docId) {
    return _firestore.collection('insurance_renewals').doc(docId).snapshots();
  }
}

class FormulaireRenouvellement extends StatefulWidget {
  final String contractId;
  final String contractNumber;
  final String typeAssurance;

  const FormulaireRenouvellement({
    super.key,
    required this.contractId,
    required this.contractNumber,
    required this.typeAssurance,
    required currentPrice,
  });

  @override
  State<FormulaireRenouvellement> createState() =>
      _FormulaireRenouvellementState();
}

class _FormulaireRenouvellementState extends State<FormulaireRenouvellement> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Personal information
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _permisController = TextEditingController();

  // Documents
  File? _carteGriseImage;
  File? _permisImage;
  File? _ccpImage;
  List<File> _vehicleImages = [];

  // Process state
  bool _paymentDone = false;
  bool _isSubmitting = false;
  String? _renewalId;
  DateTime? _submissionTime;

  int _currentStep = 0;
  final List<Step> _steps = [
    const Step(
      title: Text('Informations'),
      content: Text('Vérifiez vos informations'),
      state: StepState.indexed,
      isActive: true,
    ),
    const Step(
      title: Text('Documents'),
      content: Text('Téléchargez les documents'),
      state: StepState.indexed,
      isActive: false,
    ),
    const Step(
      title: Text('Paiement'),
      content: Text('Effectuez le paiement'),
      state: StepState.indexed,
      isActive: false,
    ),
    const Step(
      title: Text('Confirmation'),
      content: Text('Suivi de votre demande'),
      state: StepState.indexed,
      isActive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // In a real app, you would load this from Firestore or your auth provider
    setState(() {
      _nomController.text = 'Mohamed Ali';
      _emailController.text = 'mohamed.ali@example.com';
      _phoneController.text = '0555123456';
      _permisController.text = '12345678';
    });
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
            Text(
              'Renouvellement ${widget.typeAssurance}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contract header
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          'Contrat: ${widget.contractNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dynamic content based on step
                  if (_currentStep == 0) _buildInfoStep(),
                  if (_currentStep == 1) _buildDocumentsStep(),
                  if (_currentStep == 2) _buildPaymentStep(),
                  if (_currentStep == 3) _buildConfirmationStep(),
                ],
              ),
            ),
          ),

          // Bottom step bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => setState(() => _currentStep--),
                      child: const Text('Précédent'),
                    ),
                  )
                else
                  const SizedBox(width: 120),

                // Step indicators
                Row(
                  children: _steps.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentStep == idx
                            ? Colors.blue
                            : (idx < _currentStep ? Colors.green : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentStep < _steps.length - 1) {
                              if (_validateStep(_currentStep)) {
                                setState(() => _currentStep++);
                              }
                            } else {
                              _submitForm();
                            }
                          },
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentStep == _steps.length - 1
                                ? 'Terminer'
                                : 'Suivant',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Information
        return _formKey.currentState?.validate() ?? false;
      case 1: // Documents
        if (_carteGriseImage == null ||
            _permisImage == null ||
            _ccpImage == null ||
            _vehicleImages.length < 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez télécharger tous les documents requis'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      case 2: // Payment
        if (!_paymentDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez compléter le paiement'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Widget _buildInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // Full name
          TextFormField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre téléphone';
              }
              if (value.length < 8) {
                return 'Numéro invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // License number
          TextFormField(
            controller: _permisController,
            decoration: const InputDecoration(
              labelText: 'Numéro de permis',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.card_membership),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de permis';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Vehicle (read-only)
          TextFormField(
            initialValue: 'Peugeot 208 - 12345678',
            decoration: const InputDecoration(
              labelText: 'Véhicule',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_car),
            ),
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents requis:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Téléchargez les documents nécessaires',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Carte Grise
        _buildDocumentCard(
          title: 'Carte Grise',
          description: 'Document officiel du véhicule',
          image: _carteGriseImage,
          onTap: () => _pickImage('carteGrise'),
        ),

        // Driver's license
        _buildDocumentCard(
          title: 'Permis de conduire',
          description: 'Recto-verso valide',
          image: _permisImage,
          onTap: () => _pickImage('permis'),
        ),

        // CCP
        _buildDocumentCard(
          title: 'CCP',
          description: 'Compte CCP pour paiement',
          image: _ccpImage,
          onTap: () => _pickImage('ccp'),
        ),

        // Vehicle photos (required)
        Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Photos du véhicule (4 angles obligatoires)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Avant, arrière, côté droit, côté gauche',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Vehicle photos gallery
                if (_vehicleImages.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: _vehicleImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Image.file(
                            _vehicleImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _vehicleImages.removeAt(index)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                    onPressed: () => _pickVehicleImages(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Ajouter des photos',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String description,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (image != null)
              Column(
                children: [
                  Image.file(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          onPressed: onTap,
                          child: const Text('Remplacer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (title == 'Carte Grise') {
                                _carteGriseImage = null;
                              }
                              if (title == 'Permis de conduire') {
                                _permisImage = null;
                              }
                              if (title == 'CCP') _ccpImage = null;
                            });
                          },
                          child: const Text('Supprimer'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  onPressed: onTap,
                  icon: const Icon(Icons.upload),
                  label: const Text(
                    'Télécharger',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paiement sécurisé:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Contract summary
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Résumé de votre renouvellement',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                _buildPaymentDetail('Type d\'assurance', widget.typeAssurance),
                _buildPaymentDetail('Contrat', widget.contractNumber),
                _buildPaymentDetail('Période', '01/01/2024 - 31/12/2024'),
                _buildPaymentDetail('Montant total', '50,000 DA'),
                const Divider(height: 30),

                // Payment methods
                const Text(
                  'Choisissez votre méthode de paiement:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // Credit card
                _buildPaymentOption(
                  icon: Icons.credit_card,
                  title: 'Carte bancaire',
                  onTap: () => _showPaymentDialog('Carte bancaire'),
                ),

                // Bank transfer
                _buildPaymentOption(
                  icon: Icons.account_balance,
                  title: 'Virement bancaire',
                  onTap: () => _showPaymentDialog('Virement bancaire'),
                ),

                // CCP
                _buildPaymentOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Paiement par CCP',
                  onTap: () => _showPaymentDialog('CCP'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final timeSinceSubmission = _submissionTime != null
        ? DateTime.now().difference(_submissionTime!).inHours
        : 0;
    final remainingTime = 4 - timeSinceSubmission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi de votre demande:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 60, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  'Demande soumise avec succès',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Contrat: ${widget.contractNumber}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Timeline
                _buildTimelineItem(
                  'Documents vérifiés',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildTimelineItem(
                  'Paiement accepté',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildTimelineItem(
                  remainingTime > 0
                      ? 'Traitement en cours ($remainingTime h restantes)'
                      : 'Traitement terminé',
                  remainingTime > 0 ? Icons.access_time : Icons.check_circle,
                  remainingTime > 0 ? Colors.orange : Colors.green,
                ),

                const SizedBox(height: 30),
                const Text(
                  'Votre compagnie traite votre demande. '
                  'Vous recevrez une notification lorsque votre contrat sera prêt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'carteGrise':
            _carteGriseImage = File(image.path);
            break;
          case 'permis':
            _permisImage = File(image.path);
            break;
          case 'ccp':
            _ccpImage = File(image.path);
            break;
        }
      });
    }
  }

  Future<void> _pickVehicleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _vehicleImages.addAll(images.map((image) => File(image.path)).toList());
        // Limit to 4 photos
        if (_vehicleImages.length > 4) {
          _vehicleImages = _vehicleImages.sublist(0, 4);
        }
      });
    }
  }

  void _showPaymentDialog(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paiement par $method'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (method == 'Carte bancaire') ...[
                const Text('Entrez vos informations de carte:'),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Numéro de carte',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'expiration (MM/AA)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Code CVV',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ] else if (method == 'Virement bancaire') ...[
                const Text('Coordonnées bancaires:'),
                const SizedBox(height: 20),
                const Text(
                  'Banque: BNA\n'
                  'Code agence: 012\n'
                  'N° compte: 1234567890\n'
                  'Clé: 12\n'
                  'RIB: 012123456789012',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Veuillez effectuer le virement et télécharger la preuve',
                  style: TextStyle(color: Colors.grey),
                ),
              ] else if (method == 'CCP') ...[
                const Text('Paiement par CCP:'),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Numéro CCP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Clé CCP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentDone = true;
                _submissionTime = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paiement par $method effectué avec succès'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare documents list (carte grise, permis, ccp + vehicle photos)
      final allDocuments = [
        _carteGriseImage!,
        _permisImage!,
        _ccpImage!,
        ..._vehicleImages
      ];

      // Prepare personal info
      final personalInfo = {
        'fullName': _nomController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'licenseNumber': _permisController.text,
      };

      // Submit to Firestore
      final renewalId = await RenewalFirestoreService.submitRenewal(
        userId: 'current_user_id', // Replace with actual user ID
        contractId: widget.contractId,
        contractNumber: widget.contractNumber,
        insuranceType: widget.typeAssurance,
        personalInfo: personalInfo,
        documents: allDocuments,
        amount: 50000, // Replace with actual amount
      );

      // Update UI
      setState(() {
        _submissionTime = DateTime.now();
        _renewalId = renewalId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Renouvellement soumis avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
