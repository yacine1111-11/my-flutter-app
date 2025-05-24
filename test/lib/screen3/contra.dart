import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class InsuranceDocumentScreen extends StatefulWidget {
  @override
  _InsuranceDocumentScreenState createState() =>
      _InsuranceDocumentScreenState();
}

class _InsuranceDocumentScreenState extends State<InsuranceDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _documentIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _insuranceType = 'Assurance complète';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 365));
  String _status = 'Actif';

  List<Map<String, dynamic>> _insuranceDocuments = [];
  int? _editingDocumentIndex;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    _insuranceDocuments = [
      {
        'id': 'DOC-2023-001',
        'customerName': 'Ahmed Mohamed',
        'personalInfo': {
          'idNumber': '1234567890',
          'phone': '0501234567',
        },
        'carInfo': {
          'model': 'Toyota Camry 2022',
          'plateNumber': 'A B C 1234',
          'chassisNumber': 'JTDKB20U677678983'
        },
        'insuranceType': 'Assurance complète',
        'status': 'Actif',
        'startDate': '2023-01-01',
        'endDate': '2024-01-01',
        'price': '1500 DA'
      }
    ];
  }

  void _editDocument(int index) {
    final doc = _insuranceDocuments[index];
    setState(() {
      _editingDocumentIndex = index;
      _documentIdController.text = doc['id'];
      _customerNameController.text = doc['customerName'];
      _idNumberController.text = doc['personalInfo']['idNumber'];
      _phoneController.text = doc['personalInfo']['phone'];
      _carModelController.text = doc['carInfo']['model'];
      _plateNumberController.text = doc['carInfo']['plateNumber'];
      _chassisNumberController.text = doc['carInfo']['chassisNumber'];
      _insuranceType = doc['insuranceType'];
      _status = doc['status'];
      _priceController.text = doc['price'];
      _startDate = DateTime.parse(doc['startDate']);
      _endDate = DateTime.parse(doc['endDate']);
    });
    _showDocumentForm();
  }

  void _showDocumentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    _editingDocumentIndex == null
                        ? 'Créer un nouveau contrat'
                        : 'Modifier le contrat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Numéro du contrat', _documentIdController),
                  _buildTextField('Nom du client', _customerNameController),
                  _buildTextField('Numéro d\'identité', _idNumberController),
                  _buildTextField('Numéro de téléphone', _phoneController),
                  _buildTextField('Modèle de véhicule', _carModelController),
                  _buildTextField('Numéro de plaque', _plateNumberController),
                  _buildTextField(
                      'Numéro de châssis', _chassisNumberController),
                  _buildDropdown(
                      'Type d\'assurance',
                      _insuranceType,
                      [
                        'Assurance complète',
                        'Assurance tiers',
                        'Assurance conducteurs'
                      ],
                      (val) => setState(() => _insuranceType = val)),
                  _buildDropdown(
                      'Statut du contrat',
                      _status,
                      ['Actif', 'Expiré', 'Annulé', 'En révision'],
                      (val) => setState(() => _status = val)),
                  _buildTextField('Prix de l\'assurance', _priceController,
                      isNumber: true),
                  _buildDateTile('Date de début', _startDate, (picked) {
                    setState(() => _startDate = picked);
                  }),
                  _buildDateTile('Date de fin', _endDate, (picked) {
                    setState(() => _endDate = picked);
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearForm();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: _saveDocument,
                        child: Text(_editingDocumentIndex == null
                            ? 'Enregistrer'
                            : 'Mettre à jour'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveDocument() {
    if (_formKey.currentState!.validate()) {
      final newDoc = {
        'id': _documentIdController.text,
        'customerName': _customerNameController.text,
        'personalInfo': {
          'idNumber': _idNumberController.text,
          'phone': _phoneController.text,
        },
        'carInfo': {
          'model': _carModelController.text,
          'plateNumber': _plateNumberController.text,
          'chassisNumber': _chassisNumberController.text,
        },
        'insuranceType': _insuranceType,
        'status': _status,
        'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
        'endDate': DateFormat('yyyy-MM-dd').format(_endDate),
        'price': _priceController.text,
      };

      setState(() {
        if (_editingDocumentIndex == null) {
          _insuranceDocuments.add(newDoc);
        } else {
          _insuranceDocuments[_editingDocumentIndex!] = newDoc;
        }
      });

      Navigator.pop(context);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contrat enregistré avec succès')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _editingDocumentIndex = null;
      _documentIdController.clear();
      _customerNameController.clear();
      _idNumberController.clear();
      _phoneController.clear();
      _carModelController.clear();
      _plateNumberController.clear();
      _chassisNumberController.clear();
      _priceController.clear();
      _insuranceType = 'Assurance complète';
      _status = 'Actif';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(Duration(days: 365));
    });
  }

  void _printContract(Map<String, dynamic> doc) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Contrat d\'assurance',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Nom du client: ${doc['customerName']}'),
            pw.Text('Téléphone: ${doc['personalInfo']['phone']}'),
            pw.Text('Identité: ${doc['personalInfo']['idNumber']}'),
            pw.SizedBox(height: 10),
            pw.Text('Modèle véhicule: ${doc['carInfo']['model']}'),
            pw.Text('Plaque: ${doc['carInfo']['plateNumber']}'),
            pw.Text('Châssis: ${doc['carInfo']['chassisNumber']}'),
            pw.SizedBox(height: 10),
            pw.Text('Type: ${doc['insuranceType']}'),
            pw.Text('Statut: ${doc['status']}'),
            pw.Text('Du ${doc['startDate']} au ${doc['endDate']}'),
            pw.Text('Prix: ${doc['price']}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Champ requis' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }

  Widget _buildDateTile(
      String label, DateTime date, Function(DateTime) onPick) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('$label : ${DateFormat('yyyy-MM-dd').format(date)}'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📄 Contrats d'assurance"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _clearForm();
              _showDocumentForm();
            },
          )
        ],
      ),
      body: _insuranceDocuments.isEmpty
          ? Center(child: Text('Aucun contrat trouvé.'))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _insuranceDocuments.length,
              itemBuilder: (context, index) {
                final doc = _insuranceDocuments[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(doc['customerName']),
                    subtitle: Text('Contrat n°: ${doc['id']}'),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') _editDocument(index);
                        if (value == 'pdf') _printContract(doc);
                        if (value == 'delete') _deleteDocument(index);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(value: 'pdf', child: Text('Générer PDF')),
                        PopupMenuItem(
                            value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _deleteDocument(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Supprimer"),
        content: Text("Voulez-vous supprimer ce contrat ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Non")),
          TextButton(
              onPressed: () {
                setState(() => _insuranceDocuments.removeAt(index));
                Navigator.pop(context);
              },
              child: Text("Oui")),
        ],
      ),
    );
  }
}
