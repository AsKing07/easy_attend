import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/etudiant/SeeMyAttendance/seeMyAttendanceMobile.dart';

import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EtudiantDashboardMobile extends StatefulWidget {
  const EtudiantDashboardMobile({super.key});

  @override
  State<EtudiantDashboardMobile> createState() =>
      _EtudiantDashboardMobileState();
}

class _EtudiantDashboardMobileState extends State<EtudiantDashboardMobile> {
  late Map<String, dynamic> etudiant;
  bool dataIsLoaded = false;
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _courseStreamController =
      StreamController<List<dynamic>>();
  final StreamController<List<dynamic>> _courseStreamController2 =
      StreamController<List<dynamic>>();

  String queryTypeFromDB = "Aucune requete en cours";

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
        queryTypeFromDB = query['type'];
        queryStatusFromDB = query["statut"];
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: !dataIsLoaded
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 35, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue ${etudiant['nom']} ${etudiant['prenom']}',
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Consulter votre Dashboard',
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20.0,
                          runSpacing: 20.0,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: (screenWidth - 10) / 2,
                                  height: 230,
                                  child: StreamBuilder(
                                    stream: _courseStreamController.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: LoadingAnimationWidget
                                              .hexagonDots(
                                                  color:
                                                      AppColors.secondaryColor,
                                                  size: 50),
                                        );
                                      } else {
                                        if (snapshot.hasError) {
                                          return errorWidget(
                                              error: snapshot.error.toString());
                                        } else {
                                          List<dynamic>? courses =
                                              snapshot.data;
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
                                                    const Icon(
                                                      Icons
                                                          .settings_applications_outlined,
                                                      color:
                                                          AppColors.courColor,
                                                      size: 70.0,
                                                    ),
                                                    const SizedBox(
                                                      height: 20.0,
                                                    ),
                                                    const Text(
                                                      "Cours",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize:
                                                            FontSize.xxLarge,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    AnimatedTextKit(
                                                      animatedTexts: [
                                                        TyperAnimatedText(
                                                          textAlign:
                                                              TextAlign.center,

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
                                SizedBox(
                                    width: (screenWidth - 10) / 2,
                                    height: 230,
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 8.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                                textAlign: TextAlign.center,
                                                queryTypeFromDB,
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: FontSize.large,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Text(
                                                textAlign: TextAlign.center,
                                                queryStatusFromDB == "2"
                                                    ? "En attente de traitement"
                                                    : queryStatusFromDB == "1"
                                                        ? "Approuvé"
                                                        : queryStatusFromDB ==
                                                                "0"
                                                            ? "Rejeté"
                                                            : queryStatusFromDB,
                                                style: TextStyle(
                                                  color: queryStatusFromDB ==
                                                          "2"
                                                      ? AppColors.studColor
                                                      : queryStatusFromDB == "1"
                                                          ? AppColors.greenColor
                                                          : AppColors.redColor,
                                                  fontSize: FontSize.medium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            )
                          ],
                        ),
                      )),
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
                                  color: AppColors.textColor,
                                  fontSize: FontSize.xxLarge,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Sélectionnez pour consulter la présence :",
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
                      height: 150, // Hauteur du conteneur principal
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
                                                  fontWeight: FontWeight.bold),
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
                                                print(_selectedCourse);
                                              },
                                              child: SizedBox(
                                                  height: 120,
                                                  width: 300,
                                                  child: CourseCard(
                                                    filiere:
                                                        etudiant['filiere'],
                                                    course: course,
                                                    onTap: () {
                                                      // TODO: SeeMyAttendancePage
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                seeMyAttendanceMobilePage(
                                                                    course:
                                                                        course)),
                                                      );
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
                    padding: const EdgeInsets.all(12),
                    child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          //   color: Color(0xFF00796B), // Couleur de fond
                          color: AppColors.primaryColor, // Couleur de fond
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Démarrer une discussion avec un personnel de votre université',
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: FontSize.large,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'assets/chat.jpeg',
                                    height: 120,
                                    width: 120,
                                  ),
                                )
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                // backgroundColor:
                                //     Color(0xFFFFC107), // Couleur du bouton
                                backgroundColor: AppColors
                                    .secondaryColor, // Couleur du bouton
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Bientôt disponible',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
    );
  }
}
