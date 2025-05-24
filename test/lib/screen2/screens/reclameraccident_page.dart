// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart'; // Pour kIsWeb

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add accident report to Firestore
  static Future<void> addAccidentReport(Map<String, dynamic> reportData) async {
    try {
      await _firestore.collection('declarations_accidents').add(reportData);
    } catch (e) {
      throw Exception('Failed to add report: $e');
    }
  }

  // Get download URL for uploaded files (you'll need to implement file upload separately)
  static Future<String> uploadFileAndGetUrl(File file, String path) async {
    // Implement your file upload logic here
    // This would typically use Firebase Storage
    return 'url_to_uploaded_file';
  }
}

class ReclamerAccidentPage extends StatefulWidget {
  const ReclamerAccidentPage({super.key});

  @override
  State<ReclamerAccidentPage> createState() => _ReclamerAccidentPageState();
}

class _ReclamerAccidentPageState extends State<ReclamerAccidentPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Données partagées entre les pages
  final AccidentData _accidentData = AccidentData();

  final List<Widget> _pages = [
    const PersonsInvolvedPage(),
    const AccidentDescriptionPage(),
    const ConfirmationPage(),
  ];

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
              'Déclarer un accident',
              style: TextStyle(
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
          // Stepper horizontal simplifié
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepIndicator(0, 'Personnes'),
                _buildStepIndicator(1, 'Accident'),
                _buildStepIndicator(2, 'Confirmation'),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
          ),

          // Barre de navigation
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => _currentStep--);
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Précédent'),
                    ),
                  )
                else
                  const SizedBox(width: 120),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_validateCurrentStep()) {
                        if (_currentStep < _pages.length - 1) {
                          setState(() => _currentStep++);
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _submitForm();
                        }
                      }
                    },
                    child: Text(
                      _currentStep == _pages.length - 1 ? 'Envoyer' : 'Suivant',
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personnes impliquées
        if (_accidentData.hasFamilyDriver &&
            (_accidentData.familyPermisImage == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Documents obligatoires manquants pour le conducteur familial'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        if (_accidentData.hasOtherDriver &&
            (_accidentData.nomCompletB.isEmpty ||
                _accidentData.numTelB.isEmpty ||
                _accidentData.permisBImage == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Informations obligatoires manquantes pour la personne B'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      case 1: // Description accident
        if (_accidentData.lieu.isEmpty ||
            _accidentData.description.isEmpty ||
            _accidentData.photosAccident.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Veuillez compléter la description et ajouter des photos'),
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

  void _submitForm() async {
    try {
      setState(() => _accidentData.submitted = true);

      // Prepare the data for Firestore
      final reportData = {
        'hasFamilyDriver': _accidentData.hasFamilyDriver,
        'hasOtherDriver': _accidentData.hasOtherDriver,
        'otherDriverInfo': {
          'nomComplet': _accidentData.nomCompletB,
          'numTel': _accidentData.numTelB,
          'permis': _accidentData.permisB,
          'compagnie': _accidentData.compagnieB,
          'adresse': _accidentData.adresseB,
          'email': _accidentData.emailB,
          'vehicule': {
            'marque': _accidentData.marqueVehiculeB,
            'modele': _accidentData.modeleVehiculeB,
            'immatriculation': _accidentData.immatriculationB,
          },
        },
        'accidentDetails': {
          'lieu': _accidentData.lieu,
          'date': _accidentData.date,
          'description': _accidentData.description,
          'photosCount': _accidentData.photosAccident.length,
        },
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      // Upload documents if they exist
      if (_accidentData.familyPermisImage != null) {
        final url = await FirebaseService.uploadFileAndGetUrl(
          _accidentData.familyPermisImage!,
          'permis_familial',
        );
        reportData['familyPermisUrl'] = url;
      }

      // Add similar uploads for other documents...

      // Upload accident photos
      final photoUrls = await Future.wait(
        _accidentData.photosAccident.map((photo) async {
          final url = await FirebaseService.uploadFileAndGetUrl(
            photo['file'] as File,
            'accident_photos/${DateTime.now().millisecondsSinceEpoch}',
          );
          return {
            'url': url,
            'type': photo['type'],
          };
        }),
      );
      reportData['photoUrls'] = photoUrls;

      // Save to Firestore
      await FirebaseService.addAccidentReport(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déclaration envoyée avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _accidentData.submitted = false);
    }
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentStep == stepIndex
                ? Colors.blue
                : (_currentStep > stepIndex ? Colors.green : Colors.grey),
          ),
          child: _currentStep > stepIndex
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontWeight:
                _currentStep == stepIndex ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class AccidentData {
  // Conducteur familial (membre de la famille assuré)
  bool hasFamilyDriver = false;
  File? familyPermisImage;
  File? familyCarteIdentiteImage;

  // Personne B (autre conducteur/victime)
  bool hasOtherDriver = false;
  String nomCompletB = '';
  String numTelB = '';
  String permisB = '';
  String compagnieB = '';
  String adresseB = '';
  String emailB = '';
  File? permisBImage;
  File? carteIdentiteBImage;
  File? contratBImage;

  // Véhicule personne B
  String marqueVehiculeB = '';
  String modeleVehiculeB = '';
  String immatriculationB = '';

  // Description accident
  String lieu = '';
  String date = '';
  String description = '';
  List<Map<String, dynamic>> photosAccident = [];

  bool submitted = false;
}

class PersonsInvolvedPage extends StatefulWidget {
  const PersonsInvolvedPage({super.key});

  @override
  State<PersonsInvolvedPage> createState() => _PersonsInvolvedPageState();
}

class _PersonsInvolvedPageState extends State<PersonsInvolvedPage> {
  final ImagePicker _picker = ImagePicker();
  late AccidentData _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = (context.findAncestorStateOfType<_ReclamerAccidentPageState>()!
            as dynamic)
        ._accidentData;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Conducteur familial
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Conducteur familial (membre assuré)'),
                      const SizedBox(width: 10),
                      Switch(
                        value: _data.hasFamilyDriver,
                        onChanged: (value) =>
                            setState(() => _data.hasFamilyDriver = value),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  if (_data.hasFamilyDriver) ...[
                    const SizedBox(height: 15),
                    const Text(
                      'Documents obligatoires:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Permis de conduire familial
                    _buildDocumentUploadCard(
                      title: 'Permis de conduire*',
                      image: _data.familyPermisImage,
                      onTap: () => _pickImage('familyPermis'),
                    ),

                    // Carte nationale d'identité familiale
                    _buildDocumentUploadCard(
                      title: 'Carte nationale d\'identité',
                      image: _data.familyCarteIdentiteImage,
                      onTap: () => _pickImage('familyCarteIdentite'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Section 2: Personne B (autre conducteur/victime)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Personne B (autre conducteur/victime)'),
                      const SizedBox(width: 10),
                      Switch(
                        value: _data.hasOtherDriver,
                        onChanged: (value) =>
                            setState(() => _data.hasOtherDriver = value),
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  if (_data.hasOtherDriver) ...[
                    const SizedBox(height: 15),
                    const Text(
                      'Informations sur la personne B:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Nom complet
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nom complet*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) => _data.nomCompletB = value,
                    ),
                    const SizedBox(height: 15),

                    // Numéro de téléphone
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => _data.numTelB = value,
                    ),
                    const SizedBox(height: 15),

                    // Compagnie d'assurance
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Compagnie d\'assurance',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      onChanged: (value) => _data.compagnieB = value,
                    ),
                    const SizedBox(height: 15),

                    // Adresse
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      onChanged: (value) => _data.adresseB = value,
                    ),
                    const SizedBox(height: 15),

                    // Email
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _data.emailB = value,
                    ),
                    const SizedBox(height: 20),

                    // Documents personne B
                    const Text(
                      'Documents obligatoires:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Permis de conduire
                    _buildDocumentUploadCard(
                      title: 'Permis de conduire*',
                      image: _data.permisBImage,
                      onTap: () => _pickImage('permisB'),
                    ),

                    // Carte nationale d'identité
                    _buildDocumentUploadCard(
                      title: 'Carte nationale d\'identité',
                      image: _data.carteIdentiteBImage,
                      onTap: () => _pickImage('carteIdentiteB'),
                    ),

                    // Contrat d'assurance
                    _buildDocumentUploadCard(
                      title: 'Contrat d\'assurance',
                      image: _data.contratBImage,
                      onTap: () => _pickImage('contratB'),
                    ),
                    const SizedBox(height: 20),

                    // Informations véhicule personne B
                    const Text(
                      'Informations sur le véhicule:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Marque
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Marque',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      onChanged: (value) => _data.marqueVehiculeB = value,
                    ),
                    const SizedBox(height: 15),

                    // Modèle
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Modèle',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      onChanged: (value) => _data.modeleVehiculeB = value,
                    ),
                    const SizedBox(height: 15),

                    // Immatriculation
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Immatriculation',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      onChanged: (value) => _data.immatriculationB = value,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
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
            Text(title),
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
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
                              if (title.contains('Permis')) {
                                if (title.startsWith('Permis') &&
                                    !title.contains('B')) {
                                  _data.familyPermisImage = null;
                                } else {
                                  _data.permisBImage = null;
                                }
                              }
                              if (title.contains('Carte')) {
                                if (title.startsWith('Carte') &&
                                    !title.contains('B')) {
                                  _data.familyCarteIdentiteImage = null;
                                } else {
                                  _data.carteIdentiteBImage = null;
                                }
                              }
                              if (title.contains('Contrat')) {
                                _data.contratBImage = null;
                              }
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
                    backgroundColor: Colors.blue,
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

  Future<void> _pickImage(String type) async {
    final option = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la source'),
        content: const Text('Comment voulez-vous obtenir le document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Appareil photo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );

    if (option != null) {
      final XFile? image = await _picker.pickImage(source: option);
      if (image != null) {
        setState(() {
          switch (type) {
            case 'familyPermis':
              _data.familyPermisImage = File(image.path);
              break;
            case 'familyCarteIdentite':
              _data.familyCarteIdentiteImage = File(image.path);
              break;
            case 'permisB':
              _data.permisBImage = File(image.path);
              break;
            case 'carteIdentiteB':
              _data.carteIdentiteBImage = File(image.path);
              break;
            case 'contratB':
              _data.contratBImage = File(image.path);
              break;
          }
        });
      }
    }
  }
}

class AccidentDescriptionPage extends StatefulWidget {
  const AccidentDescriptionPage({super.key});

  @override
  State<AccidentDescriptionPage> createState() =>
      _AccidentDescriptionPageState();
}

class _AccidentDescriptionPageState extends State<AccidentDescriptionPage> {
  final ImagePicker _picker = ImagePicker();
  late AccidentData _data;
  String _currentPhotoType = 'avant';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = (context.findAncestorStateOfType<_ReclamerAccidentPageState>()!
            as dynamic)
        ._accidentData;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description de l\'accident:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Lieu
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Lieu*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
            onChanged: (value) => _data.lieu = value,
          ),
          const SizedBox(height: 15),

          // Date
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Date et heure',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 15),

          // Description
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description*',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez décrire l\'accident';
              }
              return null;
            },
            onChanged: (value) => _data.description = value,
          ),
          const SizedBox(height: 20),

          // Photos de l'accident
          const Text(
            'Photos de l\'accident*:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Veuillez ajouter au moins 2 photos montrant les dégâts',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 15),
          _buildPhotoTypeSelector(),
          // Sélecteur de type de photo
          if (_data.photosAccident.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _data.photosAccident.length,
              itemBuilder: (context, index) {
                final file = _data.photosAccident[index]['file'];
                final type = _data.photosAccident[index]['type'] as String;

                return Stack(
                  children: [
                    Positioned.fill(child: _buildImage(file)),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        color: Colors.black54,
                        child: Text(
                          type,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _data.photosAccident.removeAt(index)),
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
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: _pickAccidentPhotos,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Ajouter des photos',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de photo:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Avant'),
              selected: _currentPhotoType == 'avant',
              onSelected: (selected) =>
                  setState(() => _currentPhotoType = 'avant'),
            ),
            ChoiceChip(
              label: const Text('Arrière'),
              selected: _currentPhotoType == 'arriere',
              onSelected: (selected) =>
                  setState(() => _currentPhotoType = 'arriere'),
            ),
            ChoiceChip(
              label: const Text('Côté droit'),
              selected: _currentPhotoType == 'droit',
              onSelected: (selected) =>
                  setState(() => _currentPhotoType = 'droit'),
            ),
            ChoiceChip(
              label: const Text('Côté gauche'),
              selected: _currentPhotoType == 'gauche',
              onSelected: (selected) =>
                  setState(() => _currentPhotoType = 'gauche'),
            ),
            ChoiceChip(
              label: const Text('Détail dégât'),
              selected: _currentPhotoType == 'detail',
              onSelected: (selected) =>
                  setState(() => _currentPhotoType = 'detail'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(dynamic file) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: file as Future<Uint8List>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(file as File, fit: BoxFit.cover);
    }
  }

  Future<void> _pickAccidentPhotos() async {
    final option = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter des photos'),
        content: const Text('Comment voulez-vous prendre les photos ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Appareil photo'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );

    if (option == null) return;

    if (option == ImageSource.camera) {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final fichier = kIsWeb ? photo.readAsBytes() : File(photo.path);
        setState(() {
          _data.photosAccident.add({
            'file': fichier,
            'type': _currentPhotoType,
          });
        });
      }
    } else {
      final List<XFile> images = await _picker.pickMultiImage();
      for (final image in images) {
        final fichier = kIsWeb ? image.readAsBytes() : File(image.path);
        setState(() {
          _data.photosAccident.add({
            'file': fichier,
            'type': _currentPhotoType,
          });
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _data.date =
              "${picked.day}/${picked.month}/${picked.year} à ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }
}

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({super.key});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late AccidentData _data;
  final bool _submitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = (context.findAncestorStateOfType<_ReclamerAccidentPageState>()!
            as dynamic)
        ._accidentData;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vérifiez les informations avant envoi:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          if (_data.hasOtherDriver) ...[
            const Text(
              'Autre conducteur:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            _buildConfirmationItem('Nom complet', _data.nomCompletB),
            _buildConfirmationItem('Téléphone', _data.numTelB),
            if (_data.permisB.isNotEmpty)
              _buildConfirmationItem('Permis', _data.permisB),
            if (_data.compagnieB.isNotEmpty)
              _buildConfirmationItem('Compagnie', _data.compagnieB),
            const SizedBox(height: 15),
            const Text(
              'Véhicule autre:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            _buildConfirmationItem('Marque', _data.marqueVehiculeB),
            if (_data.modeleVehiculeB.isNotEmpty)
              _buildConfirmationItem('Modèle', _data.modeleVehiculeB),
            _buildConfirmationItem('Immatriculation', _data.immatriculationB),
            const SizedBox(height: 15),
          ],

          const Text(
            'Accident:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          _buildConfirmationItem('Lieu', _data.lieu),
          if (_data.date.isNotEmpty) _buildConfirmationItem('Date', _data.date),
          _buildConfirmationItem('Description', _data.description),
          _buildConfirmationItem(
              'Photos', '${_data.photosAccident.length} photos'),

          // Affichage des types de photos
          if (_data.photosAccident.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (var type in [
                  'avant',
                  'arriere',
                  'droit',
                  'gauche',
                  'detail'
                ])
                  if (_data.photosAccident.any((p) => p['type'] == type))
                    Chip(
                      label: Text(
                        '$type: ${_data.photosAccident.where((p) => p['type'] == type).length}',
                      ),
                    ),
              ],
            ),
          ],

          const SizedBox(height: 30),
          if (_submitted)
            const Column(
              children: [
                Icon(Icons.check_circle, size: 60, color: Colors.green),
                SizedBox(height: 20),
                Text(
                  'Déclaration envoyée avec succès',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Votre compagnie traitera votre demande sous 48h',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else
            const Text(
              'En cliquant sur "Envoyer", vous confirmez l\'exactitude de ces informations',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
