import 'package:easy_attend/Screens/admin/AdminHome.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:easy_attend/Screens/etudiant/EtudiantHome.dart';
import 'package:easy_attend/Screens/professeur/ProfHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //Initialiser Firebase

  await dotenv.load(fileName: ".env");
  checkLocalisation();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    prefs: prefs,
  ));
}

//Fonction de demande des permissions de service localisation
Future checkLocalisation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    loc.Location.instance.requestService();
    // print("Les services de géolocalisation sont désactivés");
  }

  permission = await Geolocator.checkPermission();

  // if (permission == LocationPermission.deniedForever) {
  //   // print(
  //   //     "Les autorisations de localisation sont définitivement refusées, nous ne pouvons pas demander d'autorisations.");
  // }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    // if (permission == LocationPermission.denied) {
    //   print('Les autorisations de localisation sont refusées');
    // }
  }
}

class MyApp extends StatelessWidget {
  final dynamic prefs;
  const MyApp({super.key, required this.prefs});

  // Ce widget est la racine de l'application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: SplashScreen(prefs: prefs));
  }
}

class SplashScreen extends StatelessWidget {
  final dynamic prefs;
  const SplashScreen({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Afficher un indicateur de chargement en attendant la vérification
        } else {
          if (snapshot.data == true) {
            // Utilisateur connecté, rediriger en fonction du rôle
            final String role = prefs.getString("role") ?? "";
            if (role == "admin") {
              return const AdminHome(); // Rediriger vers la page d'administration
            } else if (role == "student") {
              return const EtudiantHome(); // Rediriger vers la page d'étudiant
            } else if (role == "prof") {
              return const ProfHome(); // Rediriger vers la page de professeur
            }
          }
          // Utilisateur non connecté, rediriger vers la page de connexion
          return const AuthPage();
        }
      },
    );
  }

  Future<bool> checkUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool loggedIn = prefs.getBool("loggedIn") ?? false;
    return loggedIn;
  }
}
