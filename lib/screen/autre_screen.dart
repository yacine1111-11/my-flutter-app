import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen2/screens/welcome_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _userName = 'Utilisateur';
  String _userEmail = 'email@exemple.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName =
          user?.displayName ?? prefs.getString('userName') ?? 'Utilisateur';
      _userEmail =
          user?.email ?? prefs.getString('userEmail') ?? 'email@exemple.com';
      _isLoading = false;
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRememberMe', false);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen2()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildUserHeader(),
                _buildSectionTitle("MON COMPTE"),
                _buildAccountOption(Icons.person, "Profil"),
                _buildAccountOption(Icons.settings, "Paramètres"),
                _buildAccountOption(Icons.security, "Sécurité"),
                _buildSectionTitle("PRÉFÉRENCES"),
                SwitchListTile(
                    title: Text('Mode sombre',
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black)),
                    value: _isDarkMode,
                    onChanged: (value) => _toggleTheme(),
                    secondary: Icon(Icons.dark_mode,
                        color: _isDarkMode ? Colors.white : Colors.black)),
                _buildSectionTitle("AIDE"),
                _buildAccountOption(Icons.support, "Support"),
                _buildAccountOption(Icons.help, "Aide"),
                const Divider(),
                _buildAccountOption(
                  Icons.logout,
                  "Déconnexion",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800] : Colors.blue,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.blue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildAccountOption(IconData icon, String title,
      {Color color = Colors.blue, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: _isDarkMode ? Colors.white : color),
      title: Text(title,
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: _isDarkMode ? Colors.white70 : Colors.grey),
      onTap: onTap,
    );
  }
}
