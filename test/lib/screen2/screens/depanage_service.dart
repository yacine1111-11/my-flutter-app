import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screen/map.dart'; // Assure-toi que ce chemin est correct

class DemandeDepanagePage extends StatefulWidget {
  const DemandeDepanagePage({super.key});

  @override
  State<DemandeDepanagePage> createState() => _DemandeDepanagePageState();
}

class _DemandeDepanagePageState extends State<DemandeDepanagePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  LatLng? _currentPosition;

  Future<void> _detectLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activez la localisation")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission refusée")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Autorisez la localisation dans les paramètres")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _locationController.text =
          "Lat: ${position.latitude.toStringAsFixed(5)}, Lon: ${position.longitude.toStringAsFixed(5)}";
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner une position")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance.collection('demandes').add({
          'nom': _nameController.text.trim(),
          'adresse': _addressController.text.trim(),
          'typeVoiture': _carTypeController.text.trim(),
          'couleurVoiture': _colorController.text.trim(),
          'probleme': _problemController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'x': _currentPosition!.latitude,
          'y': _currentPosition!.longitude,
          'date': Timestamp.now(),
        });

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚗 Demande envoyée avec succès !')),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur d'envoi : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Demande de dépannage'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCardField(Icons.person, 'Nom', _nameController, false),
              const SizedBox(height: 10),
              _buildCardField(Icons.home, 'Adresse', _addressController, false),
              const SizedBox(height: 10),
              _buildCardField(Icons.directions_car, 'Type de voiture',
                  _carTypeController, false),
              const SizedBox(height: 10),
              _buildCardField(Icons.color_lens, 'Couleur de la voiture',
                  _colorController, false),
              const SizedBox(height: 10),
              _buildCardField(Icons.report_problem, 'Problème rencontré',
                  _problemController, true),
              const SizedBox(height: 10),
              _buildLocationField(),
              if (_currentPosition != null)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 10),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentPosition!,
                      initialZoom: 14,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on,
                              size: 40, color: Colors.red),
                        )
                      ])
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              _buildCardField(
                Icons.phone,
                'Numéro de téléphone',
                _phoneController,
                false,
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildButton(
                      '📨 Envoyer la demande', _submitForm, Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _locationController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Appuyez sur 📍 pour détecter ou sélectionner',
                ),
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: ClientLocation(
                      _currentPosition?.latitude ?? 36.75,
                      _currentPosition?.longitude ?? 3.06,
                    ),
                  );

                  if (result != null && result is LatLng) {
                    setState(() {
                      _currentPosition = result;
                      _locationController.text =
                          "Lat: ${result.latitude.toStringAsFixed(5)}, Lon: ${result.longitude.toStringAsFixed(5)}";
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: _detectLocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardField(IconData icon, String label,
      TextEditingController controller, bool isMultiline,
      {String? hint,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: isMultiline ? 5 : 1,
              keyboardType: keyboardType,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: validator ??
                  (value) => value!.isEmpty ? 'Ce champ est requis' : null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Numéro requis';
    final regex = RegExp(r'^(05|06|07)[0-9]{8}$');
    if (!regex.hasMatch(value)) return 'Numéro invalide. Ex : 06XXXXXXXX';
    return null;
  }
}
