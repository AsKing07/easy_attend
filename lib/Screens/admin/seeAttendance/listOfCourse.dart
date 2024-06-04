// ignore_for_file: file_names, camel_case_types, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

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

class listOfCourse extends StatefulWidget {
  const listOfCourse({super.key});

  @override
  State<listOfCourse> createState() => _listOfCourseState();
}

class _listOfCourseState extends State<listOfCourse> {
  bool dataIsLoaded = false;
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  final BACKEND_URL = dotenv.env['API_URL'];

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
      dataIsLoaded = true;
    });
  }

  Future<void> fetchData() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${_selectedFiliere?.idDoc}'));

      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _streamController.add(courses);
      } else {
        throw Exception('Erreur lors de la récupération des cours');
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
    loadAllActifFilieres();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth > 600
        ? 2 / 1
        : 1.2; // Plus de hauteur pour les petits écrans

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
                      'Sélectionnez un cours pour consulter la présence',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20.0),
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
                          border: OutlineInputBorder(),
                          labelText: 'Choisissez une filière'),
                    ),
                    const SizedBox(height: 16),
                    _selectedFiliere == null
                        ? const Center(
                            child: Text(
                                'Sélectionnez une filière pour afficher les cours de la filière uniquement'),
                          )
                        : StreamBuilder(
                            stream: _streamController.stream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: LoadingAnimationWidget.hexagonDots(
                                      color: AppColors.secondaryColor,
                                      size: 100),
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: aspectRatio,
                                    ),
                                    itemCount: courses.length,
                                    itemBuilder: (context, index) {
                                      return CourseCard(
                                        name: courses[index]['nomCours'],
                                        niveau: courses[index]['niveau'],
                                        filiere: _selectedFiliere?.idFiliere,
                                        option: "admin",
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
