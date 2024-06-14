import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_Dashboard_Mobile.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_Dashboard_Web.dart';

import 'package:flutter/material.dart';

class EtudiantDashboard extends StatefulWidget {
  const EtudiantDashboard({super.key});

  @override
  State<EtudiantDashboard> createState() => _EtudiantDashboardState();
}

class _EtudiantDashboardState extends State<EtudiantDashboard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > 1200
        //Large screen
        ? const EtudiantDashboardWeb()
        //Mobile screen
        : const EtudiantDashboardMobile();
  }
}
