// ignore_for_file: non_constant_identifier_names, file_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
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
  late Map<String, dynamic> prof;
  bool dataIsLoaded = false;
  List<Widget> myWidgets = [];
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  Widget createCourseList(List<Widget> myWidget) {
    if (myWidget.isNotEmpty) {
      return Column(
        children: [for (var w in myWidget) w],
      );
    } else {
      return const Center(child: NoResultWidget());
    }
  }

  void loadProf() async {
    final x = await get_Data().loadCurrentProfData();
    setState(() {
      prof = x;
      dataIsLoaded = true;
    });
  }

  Future<void> loadAllActifFilieres() async {
    List<dynamic> docsFiliere = await get_Data().getActifFiliereData(context);
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      Filiere filiere = Filiere(
        idDoc: doc['idFiliere'].toString(),
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["sigleFiliere"],
        statut: doc["statut"] == 1,
        niveaux: doc['niveaux'].split(','),
      );

      fil.add(filiere);
    }

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  Future<void> fetchData() async {
    // final x = await get_Data().loadCurrentProfData();
    // setState(() {
    //   prof = x;
    //   dataIsLoaded = true;
    // });
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${_selectedFiliere?.idDoc}&idProf=${prof['uid']}'));

      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _streamController.add(courses);
      } else {
        throw Exception('Erreur lors de la récupération des cours');
      }
    } catch (e) {
      // Gérer les erreurs ici
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de récupérer les cours. Erreur:$e'),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // Récupérez les données dU prof à partir de Firebase
    loadProf();
    loadAllActifFilieres();
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15.0),
                    // ignore: prefer_const_constructors
                    Text(
                      'Sélectionnez un de vos cours pour gérer la présence',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    //Dropdown Filieres
                    DropdownButtonFormField<Filiere>(
                      value: _selectedFiliere,
                      elevation: 18,
                      onChanged: (Filiere? value) {
                        setState(() {
                          _selectedFiliere = value!;
                          fetchData();
                        });
                      },
                      items: Allfilieres.map<DropdownMenuItem<Filiere>>(
                          (Filiere value) {
                        return DropdownMenuItem<Filiere>(
                          value: value,
                          child: Text(value.nomFiliere),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                          labelText: 'Choisissez une filière'),
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    _selectedFiliere == null
                        ? const Center(
                            child: Text(
                                'Sélectionnez une filière pour afficher vos cours attribués'),
                          )
                        : StreamBuilder(
                            stream: _streamController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
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
                                              filiere:
                                                  _selectedFiliere?.idFiliere,
                                              option: "professeur",
                                              course: previous,
                                            ),
                                            const SizedBox(
                                              width: 20.0,
                                            ),
                                            CourseCard(
                                              name: object['nomCours'],
                                              niveau: object['niveau'],
                                              filiere:
                                                  _selectedFiliere?.idFiliere,
                                              option: "professeur",
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
                                          filiere: _selectedFiliere?.idFiliere,
                                          option: "professeur",
                                          course: previous,
                                        ),
                                      ]));
                                }

                                return createCourseList(myWidgets);
                              } else {
                                return Material(
                                  child: Center(
                                    child: LoadingAnimationWidget.hexagonDots(
                                        color: AppColors.secondaryColor,
                                        size: 200),
                                  ),
                                );
                              }
                            })
                  ],
                ),
              ),
            ),
    );
  }
}
