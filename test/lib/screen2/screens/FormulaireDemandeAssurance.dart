// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Pour kIsWeb

class FormulaireDemandeAssurance extends StatefulWidget {
  final String typeAssurance;

  const FormulaireDemandeAssurance({super.key, required this.typeAssurance});

  @override
  State<FormulaireDemandeAssurance> createState() =>
      _FormulaireDemandeAssuranceState();
}

class _FormulaireDemandeAssuranceState
    extends State<FormulaireDemandeAssurance> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _selectedSex;
  final List<dynamic> _vehiclePhotos = [];
  final ImagePicker _picker = ImagePicker();

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _nomCompletController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numTelController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _numCarteController = TextEditingController();
  final TextEditingController _ccpController = TextEditingController();

  // Permis
  final TextEditingController _permisCategorieController =
      TextEditingController();
  final TextEditingController _permisNumeroController = TextEditingController();
  final TextEditingController _permisDateDebutController =
      TextEditingController();
  final TextEditingController _permisDateExpirationController =
      TextEditingController();

  // Véhicule
  String? _selectedMarque;
  String? _selectedModele;
  final TextEditingController _vehiculeAnneeController =
      TextEditingController();
  final TextEditingController _vehiculeMatriculationController =
      TextEditingController();
  final TextEditingController _vehiculeKilometrageController =
      TextEditingController();
  final TextEditingController _vehiculeNumeroChassisController =
      TextEditingController();
  final TextEditingController _carteGriseController = TextEditingController();

  // Paiement
  String? _methodePaiement;
  final TextEditingController _detailsPaiementController =
      TextEditingController();

  // Statut
  String? _statut;

  // Listes de sélection
  final List<String> _marquesVoitures = [
    'Toyota',
    'Renault',
    'Peugeot',
    'Hyundai',
    'Kia',
    'Mercedes',
    'BMW',
    'Audi',
    'Volkswagen',
    'Dacia',
    'Chevrolet',
    'Ford',
    'Nissan',
    'Mitsubishi',
    'Citroën',
    'Opel',
    'Fiat',
    'Seat',
    'Skoda',
    'Honda',
    'Suzuki'
  ];

  final Map<String, List<String>> _modelesParMarque = {
    'Toyota': ['Corolla', 'Yaris', 'RAV4', 'Hilux', 'Camry'],
    'Renault': ['Clio', 'Megane', 'Twingo', 'Kadjar', 'Captur'],
    'Peugeot': ['208', '308', '3008', '5008', 'Partner'],
    'Hyundai': ['i10', 'i20', 'i30', 'Tucson', 'Santa Fe'],
    'Kia': ['Picanto', 'Rio', 'Sportage', 'Sorento', 'Ceed'],
    'Mercedes': ['Classe A', 'Classe C', 'Classe E', 'GLA', 'GLC'],
    'BMW': ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3'],
    'Audi': ['A1', 'A3', 'A4', 'Q3', 'Q5'],
    'Volkswagen': ['Polo', 'Golf', 'Passat', 'Tiguan', 'T-Roc'],
    'Dacia': ['Sandero', 'Logan', 'Duster', 'Lodgy', 'Spring'],
    'Chevrolet': ['Spark', 'Aveo', 'Cruze', 'Captiva', 'Trax'],
    'Ford': ['Fiesta', 'Focus', 'Kuga', 'Puma', 'Ranger'],
    'Nissan': ['Micra', 'Qashqai', 'X-Trail', 'Juke', 'Leaf'],
    'Mitsubishi': ['Space Star', 'ASX', 'Outlander', 'Pajero', 'L200'],
    'Citroën': ['C3', 'C4', 'C5 Aircross', 'Berlingo', 'Jumpy'],
    'Opel': ['Corsa', 'Astra', 'Mokka', 'Crossland', 'Insignia'],
    'Fiat': ['500', 'Panda', 'Tipo', '500X', 'Doblo'],
    'Seat': ['Ibiza', 'Leon', 'Arona', 'Ateca', 'Tarraco'],
    'Skoda': ['Fabia', 'Octavia', 'Karoq', 'Kodiaq', 'Superb'],
    'Honda': ['Jazz', 'Civic', 'CR-V', 'HR-V', 'Accord'],
    'Suzuki': ['Swift', 'Ignis', 'Vitara', 'S-Cross', 'Jimny'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Demande ${widget.typeAssurance} - Étape ${_currentStep + 1}/3'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: Stepper(
          currentStep: _currentStep,
          // Modifiez les conditions dans onStepContinue:
          onStepContinue: () {
            if (_currentStep == 0) {
              // Supprimez la validation pour la première étape
              setState(() => _currentStep += 1);
            } else if (_currentStep == 1) {
              // Supprimez la condition sur les photos
              setState(() => _currentStep += 1);
            } else if (_currentStep == 2) {
              // Gardez seulement la validation du paiement si nécessaire
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [
            // Étape 1: Informations personnelles, permis et véhicule
            Step(
              title: const Text('Informations'),
              content: _buildPersonalInfoStep(),
              isActive: _currentStep >= 0,
            ),
            // Étape 2: Documents et photos
            Step(
              title: const Text('Documents'),
              content: _buildDocumentsStep(),
              isActive: _currentStep >= 1,
            ),
            // Étape 3: Paiement
            Step(
              title: const Text('Paiement'),
              content: _buildPaymentStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  // Étape 1: Informations personnelles, permis et véhicule
  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Section: Informations personnelles
            _buildSectionHeader('Informations personnelles', Icons.person),

            // Sexe
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: InputDecoration(
                labelText: 'Sexe',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['Homme', 'Femme'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSex = newValue;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _nomCompletController,
              label: 'Nom complet (Nom et Prénom)',
              icon: Icons.badge,
            ),
            SizedBox(width: 10),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _numTelController,
              label: 'Numéro de téléphone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextField(
              controller: _adresseController,
              label: 'Adresse complète',
              icon: Icons.home,
            ),
            _buildDateField(
              controller: _dateNaissanceController,
              label: 'Date de naissance',
              icon: Icons.cake,
            ),
            _buildTextField(
              controller: _numCarteController,
              label: 'Numéro de carte nationale',
              icon: Icons.credit_card,
            ),
            _buildTextField(
              controller: _ccpController,
              label: 'CCP (20 chiffres)',
              icon: Icons.account_balance,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            // Section: Permis de conduire
            _buildSectionHeader('Permis de conduire', Icons.drive_eta),
            _buildTextField(
              controller: _permisCategorieController,
              label: 'Catégorie (B, C, D...)',
              icon: Icons.category,
            ),
            _buildTextField(
              controller: _permisNumeroController,
              label: 'Numéro de permis',
              icon: Icons.numbers,
            ),
            _buildDateField(
              controller: _permisDateDebutController,
              label: 'Date d\'obtention',
              icon: Icons.date_range,
            ),
            _buildDateField(
              controller: _permisDateExpirationController,
              label: 'Date d\'expiration',
              icon: Icons.event_busy,
            ),

            // Section: Véhicule
            _buildSectionHeader(
                'Informations du véhicule', Icons.directions_car),
            DropdownButtonFormField<String>(
              value: _selectedMarque,
              decoration: InputDecoration(
                labelText: 'Marque du véhicule',
                prefixIcon: const Icon(Icons.branding_watermark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _marquesVoitures.map((marque) {
                return DropdownMenuItem(
                  value: marque,
                  child: Text(marque),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMarque = value;
                  _selectedModele =
                      null; // Reset le modèle quand la marque change
                });
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedModele,
              decoration: InputDecoration(
                labelText: 'Modèle du véhicule',
                prefixIcon: const Icon(Icons.model_training),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _selectedMarque != null
                  ? _modelesParMarque[_selectedMarque]!.map((modele) {
                      return DropdownMenuItem(
                        value: modele,
                        child: Text(modele),
                      );
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  _selectedModele = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _vehiculeAnneeController,
              label: 'Année de fabrication',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            _buildTextField(
              controller: _vehiculeMatriculationController,
              label: 'Matriculation',
              icon: Icons.confirmation_number,
            ),
            _buildTextField(
              controller: _vehiculeKilometrageController,
              label: 'Kilométrage',
              icon: Icons.speed,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _vehiculeNumeroChassisController,
              label: 'Numéro de chassis',
              icon: Icons.confirmation_number,
            ),
            _buildTextField(
              controller: _carteGriseController,
              label: 'Numéro de carte grise',
              icon: Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  // Étape 2: Documents et photos
  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSectionHeader('Documents obligatoires', Icons.folder),
          _buildDocumentCard('Carte nationale d\'identité', Icons.credit_card),
          _buildDocumentCard('Permis de conduire', Icons.drive_eta),
          _buildDocumentCard('Carte grise', Icons.description),
          _buildDocumentCard('CCP', Icons.account_balance),

          _buildSectionHeader(
              'Photos du véhicule (4 angles minimum)', Icons.camera_alt),
          Text(
            'Veuillez prendre des photos claires sous différents angles (avant, arrière, côtés)',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Galerie de photos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _vehiclePhotos.length + 1, // +1 pour le bouton "ajouter"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddPhotoButton();
              }
              final photo = _vehiclePhotos[index - 1];
              return Stack(
                children: [
                  Positioned.fill(child: _buildPhoto(photo)),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _vehiclePhotos.removeAt(index - 1)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_vehiclePhotos.length < 4)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${4 - _vehiclePhotos.length} photos restantes',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoto(dynamic photo) {
    if (kIsWeb) {
      // Sur le web, la photo est un Uint8List
      if (photo is Uint8List) {
        return Image.memory(
          photo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        return const Center(child: Text('Format non supporté'));
      }
    } else {
      // Sur mobile/desktop, la photo est un File
      if (photo is File) {
        return Image.file(
          photo,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        return const Center(child: Text('Fichier invalide'));
      }
    }
  }

  // Étape 3: Paiement
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Méthode de paiement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _methodePaiement,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Choisissez votre méthode de paiement',
              prefixIcon: Icon(Icons.payment),
            ),
            items: const [
              DropdownMenuItem(value: 'CCP', child: Text('Paiement par CCP')),
              DropdownMenuItem(value: 'Carte', child: Text('Carte bancaire')),
              DropdownMenuItem(value: 'Mobile', child: Text('Paiement mobile')),
            ],
            onChanged: (value) {
              setState(() {
                _methodePaiement = value;
                _detailsPaiementController.clear();
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner une méthode';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          if (_methodePaiement != null) ...[
            Text(
              _methodePaiement == 'CCP'
                  ? 'Informations CCP'
                  : _methodePaiement == 'Carte'
                      ? 'Informations carte bancaire'
                      : 'Informations paiement mobile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _detailsPaiementController,
              decoration: InputDecoration(
                labelText: _methodePaiement == 'CCP'
                    ? 'Numéro CCP (20 chiffres)'
                    : _methodePaiement == 'Carte'
                        ? 'Numéro de carte (16 chiffres)'
                        : 'Numéro de téléphone',
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                    _methodePaiement == 'Carte' ? 16 : 20),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (_methodePaiement == 'CCP' && value.length != 20) {
                  return 'Le CCP doit contenir 20 chiffres';
                }
                if (_methodePaiement == 'Carte' && value.length != 16) {
                  return 'Le numéro de carte doit contenir 16 chiffres';
                }
                if (_methodePaiement == 'Mobile' && value.length != 10) {
                  return 'Numéro de téléphone invalide';
                }
                return null;
              },
            ),
            if (_methodePaiement == 'CCP') ...[
              const SizedBox(height: 20),
              _buildPaymentInfoCard(
                title: 'Instructions de paiement par CCP',
                icon: Icons.account_balance,
                children: [
                  const Text('Veuillez effectuer le virement à:'),
                  const SizedBox(height: 10),
                  const Text('Entreprise:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Compagnie d\'Assurance ${widget.typeAssurance}'),
                  const SizedBox(height: 10),
                  const Text('CCP:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('123 456 789 123 456 789 12'),
                  const SizedBox(height: 10),
                  const Text('Banque:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Banque Nationale d\'Algérie'),
                  const SizedBox(height: 10),
                  const Text('Montant:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_calculateInsurancePrice(),
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
            if (_methodePaiement == 'Carte') ...[
              const SizedBox(height: 20),
              _buildPaymentInfoCard(
                title: 'Sécurité des paiements',
                icon: Icons.security,
                children: [
                  const Text('Vos informations bancaires sont sécurisées:'),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 5),
                      Text('Cryptage SSL 256 bits'),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 5),
                      Text('Certifié PCI DSS'),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 5),
                      Text('Aucune donnée stockée'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Montant à payer:'),
                  Text(_calculateInsurancePrice(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            if (_methodePaiement == 'Mobile') ...[
              const SizedBox(height: 20),
              _buildPaymentInfoCard(
                title: 'Instructions paiement mobile',
                icon: Icons.phone_android,
                children: [
                  const Text('Pour payer via mobile money:'),
                  const SizedBox(height: 10),
                  const Text('1. Allez dans l\'application de votre opérateur'),
                  const Text('2. Sélectionnez "Paiement de facture"'),
                  Text(
                      '3. Entrez le code: ASSUR${widget.typeAssurance.substring(0, 3)}'),
                  const Text('4. Confirmez le paiement'),
                  const SizedBox(height: 10),
                  const Text('Montant:'),
                  Text(_calculateInsurancePrice(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Widgets helper
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(date);
          }
        },
        validator: validator,
      ),
    );
  }

  Widget _buildDocumentCard(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () => _pickDocument(source: ImageSource.camera),
            ),
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: () => _pickDocument(source: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickVehiclePhoto,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
              Text('Ajouter photo'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(File photo) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            photo,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => setState(() => _vehiclePhotos.remove(photo)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[800]),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // Méthodes utilitaires
  Future<void> _pickDocument({required ImageSource source}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Document ajouté depuis ${source == ImageSource.camera ? 'appareil photo' : 'galerie'}')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickVehiclePhoto() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _vehiclePhotos.add(bytes)); // Uint8List
        } else {
          setState(() => _vehiclePhotos.add(File(pickedFile.path))); // File
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    }
  }

  String _calculateInsurancePrice() {
    switch (widget.typeAssurance) {
      case 'Tous Risques':
        return '50,000 DZD/an';
      case 'Tiers Collision':
        return '28,000 DZD/an';
      case 'Incendie/Vol':
        return '33,000 DZD/an';
      case 'Tiers Simple':
        return '16,000 DZD/an';
      default:
        return 'Prix à déterminer';
    }
  }

  bool _validatePaymentStep() {
    if (_methodePaiement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner une méthode de paiement')),
      );
      return false;
    }

    if (_detailsPaiementController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Veuillez entrer votre ${_methodePaiement == 'CCP' ? 'CCP' : _methodePaiement == 'Carte' ? 'numéro de carte' : 'numéro de téléphone'}')),
      );
      return false;
    }

    return true;
  }

  void _submitForm() async {
    setState(() => _statut = 'En attente');

    try {
      await FirebaseFirestore.instance.collection('demandes_assurance').add({
        'typeAssurance': widget.typeAssurance,
        'nomComplet': _nomCompletController.text,
        'email': _emailController.text,
        'telephone': _numTelController.text,
        'adresse': _adresseController.text,
        'dateNaissance': _dateNaissanceController.text,
        'sexe': _selectedSex,
        'numCarteNationale': _numCarteController.text,
        'ccp': _ccpController.text,
        'categoriePermis': _permisCategorieController.text,
        'numeroPermis': _permisNumeroController.text,
        'dateDebutPermis': _permisDateDebutController.text,
        'dateExpirationPermis': _permisDateExpirationController.text,
        'marqueVehicule': _selectedMarque,
        'modeleVehicule': _selectedModele,
        'anneeVehicule': _vehiculeAnneeController.text,
        'matriculation': _vehiculeMatriculationController.text,
        'kilometrage': _vehiculeKilometrageController.text,
        'numeroChassis': _vehiculeNumeroChassisController.text,
        'carteGrise': _carteGriseController.text,
        'methodePaiement': _methodePaiement,
        'detailsPaiement': _detailsPaiementController.text,
        'statut': 'En attente',
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Demande envoyée'),
          content: const Text(
              'Votre demande d\'assurance a été soumise avec succès. Vous recevrez une réponse sous 48h.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showStatusPage();
              },
              child: const Text('Voir le statut'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Firestore: $e')),
      );
    }
  }

  void _showStatusPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Statut de la demande'),
            backgroundColor: Colors.blue[800],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  'Votre demande est en cours de traitement',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Simulation de réponse après 5 secondes
                    Future.delayed(const Duration(seconds: 5), () {
                      setState(() {
                        _statut = ['Accepté', 'Refusé'][Random().nextInt(2)];
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      _showFinalStatus();
                    });
                  },
                  child: const Text('Actualiser le statut'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showFinalStatus() {
  // ignore: duplicate_ignore
  // ignore: no_leading_underscores_for_local_identifiers
  var _statut;
  final isAccepted = _statut == 'Accepté';
  final icon = isAccepted ? Icons.check_circle : Icons.error;
  final color = isAccepted ? Colors.green : Colors.red;
  final title = isAccepted ? 'Demande Acceptée' : 'Demande Refusée';
  final message = isAccepted
      ? 'Félicitations! Votre demande d\'assurance a été acceptée. Vous recevrez votre contrat par email sous 24 heures.'
      : 'Malheureusement, votre demande a été refusée. Veuillez contacter notre service client pour plus d\'informations.';

  var context;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context); // Retour à l'écran précédent
          },
          child: const Text('Retour à l\'accueil'),
        ),
        if (isAccepted) ...[
          TextButton(
            onPressed: () {
              // Action pour télécharger le contrat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Téléchargement du contrat en cours...')),
              );
            },
            child: const Text('Télécharger le contrat'),
          ),
        ],
      ],
    ),
  );
}
