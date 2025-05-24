import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String role;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserAccount.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserAccount(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }
}

class AdminAccountPage extends StatefulWidget {
  @override
  _AdminAccountPageState createState() => _AdminAccountPageState();
}

class _AdminAccountPageState extends State<AdminAccountPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  int _notificationCount = 0;

  Future<void> _deleteAccount(String accountId) async {
    try {
      await _firestore.collection('users').doc(accountId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Compte supprimé avec succès.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur lors de la suppression: ${e.toString()}")),
      );
    }
  }

  Future<void> _loadNotificationCount() async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    setState(() {
      _notificationCount = snapshot.size;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Comptes'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.notification_add),
                color: Colors.blue,
                onPressed: () {},
              ),
              Positioned(
                right: 0,
                top: 4,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '$_notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun compte utilisateur trouvé'));
          }

          final accounts = snapshot.data!.docs.map((doc) {
            return UserAccount.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: account.role == "admin"
                        ? Colors.amberAccent.withOpacity(0.4)
                        : Colors.blueAccent.withOpacity(0.4),
                    child: Icon(
                      account.role == "admin"
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color:
                          account.role == "admin" ? Colors.amber : Colors.blue,
                    ),
                  ),
                  title: Text(
                    account.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text("Email: ${account.email}\nRôle: ${account.role}"),
                  trailing: account.role != "admin"
                      ? IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Supprimer le compte"),
                                content: Text(
                                    "Êtes-vous sûr de vouloir supprimer le compte de ${account.name} ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text("Annuler"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteAccount(account.id);
                                    },
                                    child: Text("Supprimer",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
