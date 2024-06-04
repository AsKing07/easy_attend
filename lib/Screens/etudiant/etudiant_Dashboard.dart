// ignore_for_file: prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
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
          content: Text('Impossible de récupérer les cours. Erreur:$e'),
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
    double aspectRatio = screenWidth > 600
        ? 2.5
        : 1 / 1.5; // Plus de hauteur pour les petits écrans

    return Scaffold(
      body: !dataIsLoaded
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15.0),
                    const Text(
                      'Sélectionnez un cours pour consulter votre présence',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    StreamBuilder(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.secondaryColor, size: 200),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Erreur : ${snapshot.error}');
                          } else {
                            List<dynamic>? courses = snapshot.data;
                            if (courses!.isEmpty) {
                              return const SingleChildScrollView(
                                child: NoResultWidget(),
                              );
                            } else {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 600
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: aspectRatio,
                                ),
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  return CourseCard(
                                    name: courses[index]['nomCours'],
                                    niveau: courses[index]['niveau'],
                                    filiere: etudiant['filiere'],
                                    option: "etudiant",
                                    course: courses[index],
                                  );
                                },
                              );
                            }
                          }
                        })
                  ],
                ),
              ),
            ),
    );
  }
}
