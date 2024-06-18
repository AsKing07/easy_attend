// ignore_for_file: file_names, camel_case_types, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/OneCourseMobilePage.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/coursePageWebWidget.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
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
  final StreamController<List<dynamic>> _coursFilterstreamController =
      StreamController<List<dynamic>>();
  final StreamController<List<dynamic>> _AllCourseStreamController =
      StreamController<List<dynamic>>();
  final BACKEND_URL = dotenv.env['API_URL'];
  dynamic _selectedCourse;

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
    http.Response response;
    try {
      await loadAllActifFilieres();
      response =
          await http.get(Uri.parse('$BACKEND_URL/api/cours/getCoursesData'));

      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _AllCourseStreamController.add(courses);
        setState(() {
          dataIsLoaded = true;
        });
      } else {
        Helper().ErrorMessage(context,
            content: "Erreur lors de la récupération des données");
      }
    } catch (e) {
      kReleaseMode
          ? Helper().ErrorMessage(context,
              content: "Erreur lors de la récupération des données")
          : Helper().ErrorMessage(context,
              content: "Erreur lors de la récupération des données: $e");
    }
  }

  Future<void> filterCourses() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${_selectedFiliere?.idDoc}'));

      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _coursFilterstreamController.add(courses);
      } else {
        Helper().ErrorMessage(context,
            content: "Une erreur innatendue s'est produite.");
        setState(() {
          _selectedFiliere = null;
        });
      }
    } catch (e) {
      // Gérer les erreurs ici
      if (mounted) {
        setState(() {
          _selectedFiliere = null;
        });
        if (kReleaseMode) {
          Helper().ErrorMessage(context,
              content: "Une erreur innatendue s'est produite.");
        } else {
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
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio =
        screenWidth > 600 ? 3 : 2; // Plus de hauteur pour les petits écrans

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Liste des cours",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: FontSize.xxLarge,
                                    fontWeight: FontWeight.w400),
                              ),
                              const Text(
                                "Sélectionnez-en un pour le gérer :",
                                style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: FontSize.medium,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              DropdownButtonHideUnderline(
                                child: GFDropdown(
                                  elevation: 18,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                  hint: const Text(
                                    'Choisissez une filière pour trier',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  border: const BorderSide(
                                      color: AppColors.secondaryColor,
                                      width: 1),
                                  dropdownColor: AppColors.secondaryColor,
                                  dropdownButtonColor: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  value: _selectedFiliere,
                                  items: Allfilieres.map<
                                      DropdownMenuItem<Filiere>>(
                                    (Filiere value) {
                                      return DropdownMenuItem<Filiere>(
                                        value: value,
                                        child: Text(
                                          value.nomFiliere,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (Filiere? value) {
                                    setState(() {
                                      _selectedFiliere = value!;
                                      filterCourses();
                                    });
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                        height: 200, // Hauteur du conteneur principal
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: StreamBuilder(
                              stream: _selectedFiliere == null
                                  ? _AllCourseStreamController.stream
                                  : _coursFilterstreamController.stream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: LoadingAnimationWidget.hexagonDots(
                                      color: AppColors.secondaryColor,
                                      size: 100,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return errorWidget(
                                      error: snapshot.error.toString());
                                } else {
                                  List<dynamic>? courses = snapshot.data;
                                  if (courses == null || courses.isEmpty) {
                                    return Card(
                                      elevation: 8.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            child: Text(
                                              'Pas de cours ici pour le moment',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: FontSize.xxLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                    );
                                  } else {
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (final course in courses)
                                            GestureDetector(
                                              onTap: () {},
                                              child: SizedBox(
                                                height: 160,
                                                width: 300,
                                                child: CourseCard(
                                                  filiere:
                                                      _selectedFiliere != null
                                                          ? _selectedFiliere!
                                                              .nomFiliere
                                                          : Allfilieres.isEmpty
                                                              ? null
                                                              : Allfilieres
                                                                  .firstWhere(
                                                                  (filiere) =>
                                                                      filiere
                                                                          .idDoc ==
                                                                      course[
                                                                          'idFiliere'],
                                                                ).nomFiliere,
                                                  course: course,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedCourse = course;
                                                    });
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         OneCoursePage(
                                                    //             course: course),
                                                    //   ),
                                                    // );
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                            ))),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: _selectedCourse == null
                          ? SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 8.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: const Padding(
                                    padding: EdgeInsets.all(50),
                                    child: Text(
                                      'Une fois que vous aurez sélectionné un cours, il apparaîtra ici',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: FontSize.xxLarge,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ))
                          : Card(
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: OneCoursePageWebWidget(
                                key: ValueKey(_selectedCourse['idCours']),
                                course: _selectedCourse,
                                nomFiliere: Allfilieres.firstWhere(
                                  (filiere) =>
                                      filiere.idDoc ==
                                      _selectedCourse['idFiliere'],
                                ).nomFiliere,
                              )),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
