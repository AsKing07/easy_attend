// ignore_for_file: prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_Dashboard_Mobile.dart';
import 'package:easy_attend/Screens/etudiant/Dashboard/etudiant_Dashboard_Web.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class EtudiantDashboard extends StatefulWidget {
  const EtudiantDashboard({super.key});

  @override
  State<EtudiantDashboard> createState() => _EtudiantDashboardState();
}

class _EtudiantDashboardState extends State<EtudiantDashboard> {
  late Map<String, dynamic> etudiant;
  bool dataIsLoaded = false;
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  void loadStudent() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      dataIsLoaded = true;
    });
  }

  Future<void> fetchData() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      dataIsLoaded = true;
    });
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${etudiant['idFiliere']}&niveau=${etudiant['niveau']}'));
      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _streamController.add(courses);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer les cours.'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: kReleaseMode
              ? const Text('Impossible de récupérer les cours.')
              : Text('Impossible de récupérer les cours. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MediaQuery.of(context).size.width > 1200
        //Large screen
        ? const EtudiantDashboardWeb()
        //Mobile screen
        : EtudiantDashboardMobile();
  }
}
