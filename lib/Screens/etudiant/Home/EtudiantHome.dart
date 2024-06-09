// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:easy_attend/Screens/etudiant/Home/EtudiantHome_Mobile.dart';
import 'package:easy_attend/Screens/etudiant/Home/EtudiantHome_Web.dart';

import 'package:flutter/material.dart';

class EtudiantHome extends StatefulWidget {
  const EtudiantHome({super.key});

  @override
  State<EtudiantHome> createState() => _EtudiantHomeState();
}

class _EtudiantHomeState extends State<EtudiantHome> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const EtudiantHomeWeb()

//Mobile screen
        : const EtudiantHomeMobile();
  }
}
