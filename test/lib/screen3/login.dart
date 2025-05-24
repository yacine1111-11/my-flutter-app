import 'package:flutter/material.dart';

import 'janibi (2).dart';
import 'janibi (3).dart';
import 'janibi (4).dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool rememberPassword = false;
  String? phoneError;
  String? passwordError;
  String selectedRole = 'agent';

  void login() {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      phoneError = null;
      passwordError = null;

      if (phone.isEmpty) {
        phoneError = "Veuillez entrer un numéro de téléphone.";
      } else if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
        phoneError =
            "Le numéro de téléphone doit contenir exactement 10 chiffres.";
      }

      if (password.isEmpty) {
        passwordError = "Veuillez entrer un mot de passe.";
      } else if (password.length < 6) {
        passwordError = "Le mot de passe doit contenir au moins 6 caractères.";
      }
    });

    if (phoneError == null && passwordError == null) {
      if (rememberPassword) {
        print("Mot de passe sauvegardé : $password");
      }

      if (selectedRole == 'admin') {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      } else if (selectedRole == 'agent') {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => DashboardScreenee()));
      } else if (selectedRole == 'gestionnaire') {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => DashboardScreeneee()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Se connecter",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    labelText: "Numéro de téléphone",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: phoneError,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Mot de passe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    errorText: passwordError,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value!;
                        });
                      },
                    ),
                    const Text("Enregistrer le mot de passe"),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Choisir le rôle:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoleRadio(
                      role: 'admin',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    RoleRadio(
                      role: 'agent',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    RoleRadio(
                      role: 'gestionnaire',
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleRadio extends StatelessWidget {
  final String role;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const RoleRadio({
    super.key,
    required this.role,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: role,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(
          role[0].toUpperCase() + role.substring(1),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
