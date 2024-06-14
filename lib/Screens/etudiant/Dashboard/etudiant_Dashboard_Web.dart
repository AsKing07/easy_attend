// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/etudiant/SeeMyAttendance/SeeMyAttendanceWebWidget.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EtudiantDashboardWeb extends StatefulWidget {
  const EtudiantDashboardWeb({super.key});

  @override
  State<EtudiantDashboardWeb> createState() => _EtudiantDashboardWebState();
}

class _EtudiantDashboardWebState extends State<EtudiantDashboardWeb> {
  String imageUrl = "assets/admin.jpg"; // Default image

  late Map<String, dynamic> etudiant;
  bool dataIsLoaded = false;
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _courseStreamController =
      StreamController<List<dynamic>>();
  final StreamController<List<dynamic>> _courseStreamController2 =
      StreamController<List<dynamic>>();

  String queryTypeFromDB = "Aucune requete en cours";
  String querySubjectFromDB = "----";
  String queryFromDB = "Vous n'avez envoyé aucune requête";
  String queryStatusFromDB = "";

  dynamic _selectedCourse;

  void loadStudent() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
    });
  }

  Future<void> fetchData() async {
    //load Student
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      imageUrl = x['image'] ?? imageUrl;
    });
    http.Response response;
    //load Student Course
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/cours/getCoursesData?idFiliere=${etudiant['idFiliere']}&niveau=${etudiant['niveau']}'));
      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _courseStreamController.add(courses);
        _courseStreamController2.add(courses);
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
    //load Student Query
    final dynamic query = await get_Data().getQueryById(x['uid'], context);
    setState(() {
      if (query.isNotEmpty) {
        querySubjectFromDB = query['sujet'];
        queryTypeFromDB = query['type'];
        queryStatusFromDB = query["statut"];
        queryFromDB = query['details'];
      }
      dataIsLoaded = true;
    });
  }

  @override
  void initState() {
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
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Column(
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
                                                      backgroundImage:
                                                          NetworkImage(
                                                        imageUrl,
                                                      ))
                                                  : GFAvatar(
                                                      radius: 40,
                                                      backgroundColor:
                                                          Colors.grey[200],
                                                      backgroundImage:
                                                          AssetImage(imageUrl),
                                                    ),
                                              const SizedBox(height: 10),
                                              Text(
                                                ' ${etudiant['nom']} ${etudiant['prenom']}',
                                                style: const TextStyle(
                                                  fontSize: FontSize.medium,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                '${etudiant['email']}',
                                                style: const TextStyle(
                                                  fontSize: FontSize.medium,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 3),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                ' ${etudiant["filiere"]}',
                                                style: const TextStyle(
                                                  fontSize: FontSize.medium,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              Text(
                                                ' ${etudiant["niveau"]}',
                                                style: const TextStyle(
                                                  fontSize: FontSize.medium,
                                                ),
                                              ),

                                              // Add more student information as needed
                                            ],
                                          ),
                                        ],
                                      )),
                                ),
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              // Deuxième contenu de la colonne
                              child: SizedBox(
                                width: 300,
                                height: 200,
                                child: StreamBuilder(
                                  stream: _courseStreamController.stream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                                color: AppColors.secondaryColor,
                                                size: 50),
                                      );
                                    } else {
                                      if (snapshot.hasError) {
                                        return errorWidget(
                                            error: snapshot.error.toString());
                                      } else {
                                        List<dynamic>? courses = snapshot.data;
                                        return Card(
                                          color: Colors.white,
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  // const Icon(
                                                  //   Icons
                                                  //       .settings_applications_outlined,
                                                  //   color: AppColors.courColor,
                                                  //   size: 70.0,
                                                  // ),
                                                  SvgPicture.asset(
                                                    height: 70,
                                                    width: 70,
                                                    'assets/courslogo.svg',
                                                  ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  const Text(
                                                    "Nombre de cours",
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize:
                                                          FontSize.xxLarge,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  AnimatedTextKit(
                                                    animatedTexts: [
                                                      TyperAnimatedText(
                                                        courses!.length
                                                            .toString(),
                                                        textStyle:
                                                            const TextStyle(
                                                          color: AppColors
                                                              .textColor,
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
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              // Troisième contenu de la colonne
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
                                            Icons.query_stats,
                                            color: AppColors.filiereColor,
                                            size: 70.0,
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          Text(
                                            queryTypeFromDB,
                                            style: const TextStyle(
                                              color: AppColors.textColor,
                                              fontSize: FontSize.xxLarge,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            queryStatusFromDB == "2"
                                                ? "En attente de traitement"
                                                : queryStatusFromDB == "1"
                                                    ? "Approuvé"
                                                    : queryStatusFromDB == "0"
                                                        ? "Rejeté"
                                                        : queryStatusFromDB,
                                            style: TextStyle(
                                              color: queryStatusFromDB == "2"
                                                  ? AppColors.studColor
                                                  : queryStatusFromDB == "1"
                                                      ? AppColors.greenColor
                                                      : AppColors.redColor,
                                              fontSize: 25.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ), //Courses List
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0, left: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Vos cours",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: FontSize.xxLarge,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "Sélectionnez en un pour consulter votre présence :",
                                style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: FontSize.medium,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                        height: 200, // Hauteur du conteneur principal
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: StreamBuilder(
                                stream: _courseStreamController2.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: LoadingAnimationWidget.hexagonDots(
                                          color: AppColors.secondaryColor,
                                          size: 100),
                                    );
                                  } else if (snapshot.hasError) {
                                    return errorWidget(
                                        error: snapshot.error.toString());
                                  } else {
                                    List<dynamic>? courses = snapshot.data;
                                    if (courses!.isEmpty) {
                                      return Card(
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Text(
                                                'Pas de cours pour le moment',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: FontSize.xxLarge,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )));
                                    } else {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (final course in courses)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCourse = course;
                                                  });
                                                },
                                                child: SizedBox(
                                                    height: 160,
                                                    width: 300,
                                                    child: CourseCard(
                                                      filiere:
                                                          etudiant['filiere'],
                                                      course: course,
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedCourse =
                                                              course;
                                                        });
                                                      },
                                                    )),
                                              )
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                }))),
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
                                      'Une fois que vous aurez sélectionné un cours, votre présence apparaîtra ici',
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
                              child: seeMyAttendanceWebWidget(
                                key: ValueKey(_selectedCourse['idCours']),
                                course: _selectedCourse,
                              )),
                    )
                  ],
                ),
              ));
  }
}
