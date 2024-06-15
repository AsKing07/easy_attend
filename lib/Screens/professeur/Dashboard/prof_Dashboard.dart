// ignore_for_file: non_constant_identifier_names, file_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard_Mobile.dart';
import 'package:easy_attend/Screens/professeur/Dashboard/prof_Dashboard_Web.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/OneCourseMobilePage.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ProfDashboard extends StatefulWidget {
  const ProfDashboard({super.key});

  @override
  State<ProfDashboard> createState() => _ProfDashboardState();
}

class _ProfDashboardState extends State<ProfDashboard> {
  // late Map<String, dynamic> prof;
  // bool dataIsLoaded = false;
  // List<Filiere> Allfilieres = [];
  // Filiere? _selectedFiliere;
  // final BACKEND_URL = dotenv.env['API_URL'];
  // final StreamController<List<dynamic>> _streamController =
  //     StreamController<List<dynamic>>();

  // void loadProf() async {
  //   final x = await get_Data().loadCurrentProfData();
  //   setState(() {
  //     prof = x;
  //     dataIsLoaded = true;
  //   });
  // }

  // Future<void> loadAllActifFilieres() async {
  //   List<dynamic> docsFiliere = await get_Data().getActifFiliereData(context);
  //   List<Filiere> fil = [];

  //   for (var doc in docsFiliere) {
  //     Filiere filiere = Filiere(
  //       idDoc: doc['idFiliere'].toString(),
  //       nomFiliere: doc["nomFiliere"],
  //       idFiliere: doc["sigleFiliere"],
  //       statut: doc["statut"] == 1,
  //       niveaux: doc['niveaux'].split(','),
  //     );

  //     fil.add(filiere);
  //   }

  //   setState(() {
  //     Allfilieres.addAll(fil);
  //   });
  // }

  // Future<void> fetchData() async {
  //   // final x = await get_Data().loadCurrentProfData();
  //   // setState(() {
  //   //   prof = x;
  //   //   dataIsLoaded = true;
  //   // });
  //   http.Response response;
  //   try {
  //     response = await http.get(Uri.parse(
  //         '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${_selectedFiliere?.idDoc}&idProf=${prof['uid']}'));

  //     if (response.statusCode == 200) {
  //       List<dynamic> courses = jsonDecode(response.body);
  //       _streamController.add(courses);
  //     } else {
  //       throw Exception('Erreur lors de la récupération des cours');
  //     }
  //   } catch (e) {
  //     // Gérer les erreurs ici
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Impossible de récupérer les cours. Erreur:$e'),
  //           duration: const Duration(seconds: 6),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // @override
  // void initState() {
  //   // Récupérez les données dU prof à partir de Firebase
  //   loadProf();
  //   loadAllActifFilieres();
  //   fetchData();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1200
        ? const ProfDashboardWeb()
        : const ProfDashboardMobile();
  }
}
