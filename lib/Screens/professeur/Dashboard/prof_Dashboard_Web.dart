// ignore_for_file: avoid_unnecessary_containers, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/coursePageWebWidget.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfDashboardWeb extends StatefulWidget {
  const ProfDashboardWeb({super.key});

  @override
  State<ProfDashboardWeb> createState() => _ProfDashboardWebState();
}

class _ProfDashboardWebState extends State<ProfDashboardWeb> {
  final BACKEND_URL = dotenv.env['API_URL'];
  bool dataIsLoaded = false;
  String imageUrl = "assets/admin.jpg"; // Default image
  late Map<String, dynamic> prof;
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  int nbreCours = 0;
  Set<dynamic> profFiliere = {};
  dynamic _selectedCourse;
  String? _selectedNiveau;
  late final TextEditingController _searchController = TextEditingController();
  String? searchTerm;

  final StreamController<List<dynamic>> _coursFilterstreamController =
      StreamController<List<dynamic>>();
  final StreamController<List<dynamic>> _AllcoursStreamController =
      StreamController<List<dynamic>>();

  Future<void> loadProf() async {
    final x = await get_Data().loadCurrentProfData();

    setState(() {
      prof = x;
      imageUrl = prof['image'] ?? imageUrl;
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
    try {
      await loadProf();
      await loadAllActifFilieres();
      http.Response response;
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idProf=${prof['uid']}'));
      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _AllcoursStreamController.add(courses);
        for (var cours in courses) {
          if (cours['idProfesseur'] == prof['uid'] &&
              !profFiliere.contains(cours['idFiliere'])) {
            setState(() {
              profFiliere.add(cours['idFiliere']);
            });
          }
        }
        setState(() {
          nbreCours = courses.length;
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
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${_selectedFiliere?.idDoc}&idProf=${prof['uid']}'));

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
    super.initState();

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
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
            : SingleChildScrollView(
                child: Column(
                  children: [
                    //Statistics
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: 300,
                                height: 200,
                                child: Card(
                                    elevation: 8.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          imageUrl.startsWith('http')
                                              ? GFAvatar(
                                                  radius: 40,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage: NetworkImage(
                                                    imageUrl,
                                                  ))
                                              : GFAvatar(
                                                  radius: 40,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      AssetImage(imageUrl),
                                                ),
                                          const SizedBox(height: 8),
                                          Text(
                                            ' ${prof['nom']} ${prof['prenom']}',
                                            style: const TextStyle(
                                              fontSize: FontSize.medium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${prof['email']}',
                                            style: const TextStyle(
                                              fontSize: FontSize.medium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '${prof['phone']}',
                                            style: const TextStyle(
                                              fontSize: FontSize.medium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  child: SizedBox(
                                width: 300,
                                height: 200,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.school,
                                            color: AppColors.courColor,
                                            size: 70.0,
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          const Text(
                                            "Filières Tenues",
                                            style: TextStyle(
                                              color: AppColors.textColor,
                                              fontSize: FontSize.xxLarge,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          AnimatedTextKit(
                                            animatedTexts: [
                                              TyperAnimatedText(
                                                profFiliere.length.toString(),
                                                textStyle: const TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: 25.0,
                                                ),
                                                speed: const Duration(
                                                    milliseconds:
                                                        100), // Vitesse de l'animation
                                              ),
                                            ],
                                            totalRepeatCount:
                                                1, // Nombre de répétitions de l'animation
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  child: SizedBox(
                                width: 300,
                                height: 200,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: SvgPicture.asset(
                                              'assets/courslogo.svg',
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          const Text(
                                            "Cours enseignés",
                                            style: TextStyle(
                                              color: AppColors.textColor,
                                              fontSize: FontSize.xxLarge,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          AnimatedTextKit(
                                            animatedTexts: [
                                              TyperAnimatedText(
                                                nbreCours.toString(),
                                                textStyle: const TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: 25.0,
                                                ),
                                                speed: const Duration(
                                                    milliseconds:
                                                        100), // Vitesse de l'animation
                                              ),
                                            ],
                                            totalRepeatCount:
                                                1, // Nombre de répétitions de l'animation
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 24.0, left: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Vos cours",
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
                              SizedBox(
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
                                                color: AppColors.secondaryColor,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                                color: AppColors.secondaryColor,
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
                                          )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(flex: 2, child: searchField)
                                  ],
                                ),
                              )
                            ])),
                    SizedBox(
                        height: 200, // Hauteur du conteneur principal
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: StreamBuilder(
                              stream: _selectedFiliere == null
                                  ? _AllcoursStreamController.stream
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
                                                height: 195,
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
              ));
  }
}
