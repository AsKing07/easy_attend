// ignore_for_file: file_names, camel_case_types, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/OneCourseMobilePage.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/coursePageWebWidget.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class listOfCourse extends StatefulWidget {
  const listOfCourse({super.key});

  @override
  State<listOfCourse> createState() => _listOfCourseState();
}

class _listOfCourseState extends State<listOfCourse> {
  bool dataIsLoaded = false;
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  String? _selectedNiveau;
  final StreamController<List<dynamic>> _coursFilterstreamController =
      StreamController<List<dynamic>>();
  final StreamController<List<dynamic>> _AllCourseStreamController =
      StreamController<List<dynamic>>();
  final BACKEND_URL = dotenv.env['API_URL'];
  dynamic _selectedCourse;
  late final TextEditingController _searchController = TextEditingController();
  String? searchTerm;

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
    bool isSmallscreen = MediaQuery.of(context).size.width < 600;
    var currentPage = Provider.of<PageModelAdmin>(context);
    TextFormField searchField = TextFormField(
      controller: _searchController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Rechercher',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.only(top: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: AppColors.secondaryColor,
            width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              const BorderSide(color: AppColors.secondaryColor, width: 3.0),
        ),
      ),
      onChanged: (value) {
        setState(() {
          searchTerm = value;
        });
      },
    );

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
                        child: Column(
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
                            !isSmallscreen
                                ? SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: DropdownButtonFormField(
                                            elevation: 18,
                                            style: const TextStyle(
                                                color: AppColors.secondaryColor,
                                                fontSize: 12),
                                            value: _selectedFiliere,
                                            items: Allfilieres.map<
                                                DropdownMenuItem<Filiere>>(
                                              (Filiere value) {
                                                return DropdownMenuItem<
                                                    Filiere>(
                                                  value: value,
                                                  child: Text(
                                                    value.nomFiliere,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (Filiere? value) {
                                              setState(() {
                                                _selectedFiliere = value!;
                                                _selectedNiveau = null;
                                                filterCourses();
                                              });
                                            },
                                            decoration: InputDecoration(
                                              label: const Text("Filière"),
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 3.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        if (_selectedFiliere != null)
                                          Expanded(
                                              flex: 2,
                                              child: DropdownButtonFormField(
                                                elevation: 18,
                                                style: const TextStyle(
                                                    color: AppColors
                                                        .secondaryColor),
                                                value: _selectedNiveau,
                                                items: _selectedFiliere!.niveaux
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                  (value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedNiveau = value!;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  label: const Text("Niveau"),
                                                  contentPadding:
                                                      const EdgeInsets.all(10),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: AppColors
                                                                .secondaryColor,
                                                            width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: AppColors
                                                                .secondaryColor,
                                                            width: 3.0),
                                                  ),
                                                ),
                                              )),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(flex: 2, child: searchField)
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField(
                                          elevation: 18,
                                          style: const TextStyle(
                                              color: AppColors.secondaryColor,
                                              fontSize: 12),
                                          value: _selectedFiliere,
                                          items: Allfilieres.map<
                                              DropdownMenuItem<Filiere>>(
                                            (Filiere value) {
                                              return DropdownMenuItem<Filiere>(
                                                value: value,
                                                child: Text(
                                                  value.nomFiliere,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          onChanged: (Filiere? value) {
                                            setState(() {
                                              _selectedFiliere = value!;
                                              _selectedNiveau = null;

                                              filterCourses();
                                            });
                                          },
                                          decoration: InputDecoration(
                                            label: const Text("Filière"),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  width: 3.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (_selectedFiliere != null)
                                          DropdownButtonFormField(
                                            elevation: 18,
                                            style: const TextStyle(
                                                color:
                                                    AppColors.secondaryColor),
                                            value: _selectedNiveau,
                                            items: _selectedFiliere!.niveaux
                                                .map<DropdownMenuItem<String>>(
                                              (value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedNiveau = value!;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              label: const Text("Niveau"),
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    width: 3.0),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        searchField
                                      ],
                                    ),
                                  )
                          ],
                        )),
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
                                  if (searchTerm != null &&
                                      searchTerm!.isNotEmpty &&
                                      courses != null) {
                                    courses = courses
                                        .where((course) => course['nomCours']
                                            .toLowerCase()
                                            .contains(
                                                searchTerm!.toLowerCase()))
                                        .toList();
                                  }
                                  if (_selectedNiveau != null &&
                                      _selectedNiveau!.isNotEmpty &&
                                      courses != null) {
                                    courses = courses
                                        .where((course) =>
                                            course['niveau'].toLowerCase() ==
                                            _selectedNiveau!.toLowerCase())
                                        .toList();
                                  }

                                  if (courses == null || courses.isEmpty) {
                                    return Card(
                                      color: Colors.orange,
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
                                                color: AppColors.white,
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
                                                height: screenSize()
                                                        .isPhone(context)
                                                    ? 160
                                                    : 195,
                                                width: screenSize()
                                                        .isPhone(context)
                                                    ? 200
                                                    : 300,
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
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            1200
                                                        ? setState(() {
                                                            _selectedCourse =
                                                                course;
                                                          })
                                                        : currentPage.updatePage(MenuItems(
                                                            text: course['nomCours'],
                                                            tap: OneCourseMobilePage(
                                                                nomFiliere: _selectedFiliere != null
                                                                    ? _selectedFiliere!.nomFiliere
                                                                    : Allfilieres.isEmpty
                                                                        ? null
                                                                        : Allfilieres.firstWhere(
                                                                            (filiere) =>
                                                                                filiere.idDoc ==
                                                                                course['idFiliere'],
                                                                          ).nomFiliere,
                                                                course: course)));
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
                    if (MediaQuery.of(context).size.width > 1200)
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: _selectedCourse == null
                            ? SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: Colors.orange,
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
                                            color: AppColors.white,
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
