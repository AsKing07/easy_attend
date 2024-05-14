// ignore_for_file: prefer_typing_uninitialized_variables, file_names

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  // late DocumentSnapshot filiere;
  bool dataIsLoaded = false;
  List<Widget> myWidgets = [];
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  Widget courseList(List<Widget> myWidget) {
    return Column(
      children: [for (var w in myWidget) w],
    );
  }

  void loadStudent() async {
    final x = await get_Data().loadCurrentStudentData();
    // await loadFiliere(x['idFiliere']);
    setState(() {
      etudiant = x;
      dataIsLoaded = true;
    });
  }

  Future<void> fetchData() async {
    final x = await get_Data().loadCurrentStudentData();
    // await loadFiliere(x['idFiliere']);
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
        print(courses);
      } else {
        throw Exception('Erreur lors de la récupération des cours');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }

  @override
  void initState() {
    // loadStudent();
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !dataIsLoaded
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 100),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              List<dynamic>? cours = snapshot.data;
                              if (cours!.isEmpty) {
                                return const SingleChildScrollView(
                                  child: NoResultWidget(),
                                );
                              } else {
                                int length = snapshot.data!.length;
                                var previous;
                                myWidgets.clear();
                                for (int i = 0; i < length; i++) {
                                  var object = snapshot.data![i];
                                  if (identical(previous, null) == false) {
                                    myWidgets.add(Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            CourseCard(
                                              name: previous['nomCours'],
                                              niveau: previous['niveau'],
                                              filiere: etudiant['filiere'],
                                              option: "etudiant",
                                              course: previous,
                                            ),
                                            const SizedBox(
                                              width: 20.0,
                                            ),
                                            CourseCard(
                                              name: object['nomCours'],
                                              niveau: object['niveau'],
                                              filiere: etudiant['filiere'],
                                              option: "etudiant",
                                              course: object,
                                            ),
                                          ]),
                                      const SizedBox(height: 10.0),
                                    ]));
                                    previous = null;
                                  } else {
                                    previous = object;
                                  }
                                }
                                if (identical(previous, null) == false) {
                                  myWidgets.add(Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CourseCard(
                                          name: previous['nomCours'],
                                          niveau: previous['niveau'],
                                          filiere: etudiant['filiere'],
                                          option: "etudiant",
                                          course: previous,
                                        ),
                                      ]));
                                }

                                return courseList(myWidgets);
                              }
                            }
                          })
                    ],
                  ),
                ),
              ));
  }
}
