import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../getLocation.dart';
import 'notifications_screen.dart';
import 'liste_demandes.dart';
import 'autre_screen.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ListeDemandes(), // Maintenant en première position
    ProfileScreen(), // Appel de l'interface AutreScreen
  ];

  void fetchLocation() async {
    LocationData? loc = await getUserLocation();
    if (loc != null) {
      print("Location: ${loc.latitude}, ${loc.longitude}");
    } else {
      print("Location not available.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search, color: Colors.blue),
            label: "Demandes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Autre",
          ),
        ],
      ),
    );
  }
}
