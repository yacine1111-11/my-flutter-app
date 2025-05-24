import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_logo.dart';
import '../widgets/gradient_background.dart';
import 'ForgetPasswordScreen.dart';
import 'RegisterScreen.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _loginUser() async {
    setState(() => _errorMessage = null);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Connexion réussie
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = "Aucun utilisateur trouvé avec cet email.";
            break;
          case 'wrong-password':
            _errorMessage = "Mot de passe incorrect.";
            break;
          case 'invalid-email':
            _errorMessage = "Email invalide.";
            break;
          default:
            _errorMessage = "Erreur : ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur inattendue.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 80),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'L\'email ne doit pas contenir de majuscules';
                          }
                          if (!value.endsWith('@gmail.com') &&
                              !value.endsWith('@yahoo.com') &&
                              !value.endsWith('@hotmail.com')) {
                            return 'Email doit être @gmail.com, @yahoo.com ou @hotmail.com';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          if (value.length < 4) {
                            return 'Le mot de passe doit contenir au moins 4 caractères';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _loginUser();
                          }
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text('Créer un compte'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
