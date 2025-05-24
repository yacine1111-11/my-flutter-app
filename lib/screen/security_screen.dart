import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  String _currentPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _currentPasswordError = '';
      _newPasswordError = '';
      _confirmPasswordError = '';
      _isLoading = true;
    });

    // Validation des champs
    if (currentPassword.isEmpty) {
      setState(() {
        _currentPasswordError = 'Veuillez entrer votre mot de passe actuel';
        _isLoading = false;
      });
      return;
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      setState(() {
        _newPasswordError =
            'Le mot de passe doit comporter au moins 6 caractères';
        _isLoading = false;
      });
      return;
    }

    if (confirmPassword.isEmpty || confirmPassword != newPassword) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Recréer l'utilisateur pour vérifier l'ancien mot de passe
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe changé avec succès')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe actuel incorrect';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'Veuillez vous reconnecter avant de changer votre mot de passe';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Changer le mot de passe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ mot de passe actuel
            TextField(
              controller: _currentPasswordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Mot de passe actuel",
                errorText: _currentPasswordError.isNotEmpty
                    ? _currentPasswordError
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ nouveau mot de passe
            TextField(
              controller: _newPasswordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Nouveau mot de passe",
                errorText:
                    _newPasswordError.isNotEmpty ? _newPasswordError : null,
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ confirmation mot de passe
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Confirmer le nouveau mot de passe",
                errorText: _confirmPasswordError.isNotEmpty
                    ? _confirmPasswordError
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Changer le mot de passe"),
            ),
          ],
        ),
      ),
    );
  }
}
