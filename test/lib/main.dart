import 'package:flutter/material.dart';
import 'screen/FormulaireDemandeDep.dart';
import 'screen/login_screen.dart';
import 'screen/map.dart';
import 'screen/menu_principal.dart';
import 'screen/register_screen.dart';
import 'screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screen2/screens/AssurancePage.dart';
import 'screen2/screens/ForgetPasswordScreen.dart';
import 'screen2/screens/LoginScreen.dart';
import 'screen2/screens/MenuPage.dart';
import 'screen2/screens/RegisterScreen.dart';
import 'screen2/screens/acheterassurance_page.dart';
import 'screen2/screens/depanage_service.dart';
import 'screen2/screens/home_page.dart';
import 'screen2/screens/mesfichiers_page.dart';
import 'screen2/screens/notifications_page.dart';
import 'screen2/screens/reclameraccident_page.dart';
import 'screen2/screens/renouveller_page.dart';
import 'screen2/screens/service_selection_page.dart';
import 'screen2/screens/welcome_screen.dart';
import 'screen3/login.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taminik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      /*initialRoute: /* user == null ?*/ '/welcome' /*: '/home'*/,
      routes: {
        '/login': (context) => LoginScreen2(),
        '/register': (context) => RegisterScreen2(),
        '/menu': (context) => MenuPrincipal(),
        '/depannage': (context) =>
            FormulaireDemandeDepannage(typeAssurance: 'Dépannage'),
        '/map': (context) => MapPage(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgetPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/assurance/home': (context) => const HomePage(),
        '/selection-type': (_) => const AssurancePage(),
        '/form-auto': (_) => const AcheterAssurancePage(),
        // '/assurance/form': (context) => FormulaireDemandeAssurance(),
        '/form-depannage': (_) => const FormulaireDemandeDepannage(
              typeAssurance: '',
            ),
        // '/assurance/renewal': (context) => CarteNotificationRenouvellement(),
        '/assurance/claim': (context) => const ReclamerAccidentPage(),
        '/depannage/home': (context) => const DemandeDepanagePage(),
        '/mes-fichiers': (context) => const MesFichiersPage(),
        '/notifications': (context) => NotificationsPage(),
        '/menu': (context) => const MenuPage(),
      },*/
    );
  }
}
