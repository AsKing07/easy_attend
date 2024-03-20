import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/authScreens/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //Initialiser Firebase

  checkLocalisation();

  runApp(const MyApp());
}

//Fonction de demande des permissions de service localisation
Future checkLocalisation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    loc.Location.instance.requestService();
    print("Les services de géolocalisation sont désactivés");
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    print(
        "Les autorisations de localisation sont définitivement refusées, nous ne pouvons pas demander d'autorisations.");
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Les autorisations de localisation sont refusées');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Ce widget est la racine de l'application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Easy",
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 30,
                    letterSpacing: 10.0,
                    fontFamily: 'HomemadeApple'),
              ),
              Text(
                "Attend",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    letterSpacing: 10.0,
                    fontFamily: 'HomemadeApple'),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.textColor,
      nextScreen: const AuthPage(),
      duration: 800,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
