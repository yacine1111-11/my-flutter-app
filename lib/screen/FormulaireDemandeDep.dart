import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormulaireDemandeDepannage extends StatefulWidget {
  final String typeAssurance;

  const FormulaireDemandeDepannage({super.key, required this.typeAssurance});

  @override
  State<FormulaireDemandeDepannage> createState() =>
      _FormulaireDemandeDepannageState();
}

class _FormulaireDemandeDepannageState
    extends State<FormulaireDemandeDepannage> {
  final _formKey = GlobalKey<FormState>();

  final _nomCompletController = TextEditingController();
  final _emailController = TextEditingController();
  final _numTelController = TextEditingController();
  final _adresseController = TextEditingController();
  final _nomServiceController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _licenceNumeroController = TextEditingController();
  final _licenceDateExpirationController = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demande de dépannage"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Informations principales"),
                _buildTextField(
                    _nomCompletController, 'Nom complet', Icons.person),
                _buildTextField(_emailController, 'Email', Icons.email,
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(
                    _numTelController, 'Numéro de téléphone', Icons.phone,
                    keyboardType: TextInputType.phone),
                _buildTextField(
                    _adresseController, 'Adresse', Icons.location_on),
                _buildTextField(
                    _nomServiceController, 'Nom du service', Icons.business),
                _buildTextField(
                    _specialiteController, 'Spécialité', Icons.star),
                const SizedBox(height: 20),
                _buildSectionTitle("Licence commerciale"),
                _buildTextField(_licenceNumeroController, 'Numéro de licence',
                    Icons.description),
                _buildDateField(_licenceDateExpirationController,
                    'Date d\'expiration', Icons.event),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Soumettre la demande"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Champ obligatoire' : null,
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Date requise' : null,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId =
          user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance.collection('demandesDepanage').add({
        'typeAssurance': widget.typeAssurance,
        'nomComplet': _nomCompletController.text,
        'email': _emailController.text,
        'numTel': _numTelController.text,
        'adresse': _adresseController.text,
        'nomService': _nomServiceController.text,
        'specialite': _specialiteController.text,
        'licenceNumero': _licenceNumeroController.text,
        'licenceDateExpiration': _licenceDateExpirationController.text,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Demande envoyée"),
          content: const Text(
              "Votre demande de dépannage a été soumise avec succès."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
