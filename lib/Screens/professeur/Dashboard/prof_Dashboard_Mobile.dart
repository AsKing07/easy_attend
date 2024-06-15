import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/professeur/CoursePage/OneCourseMobilePage.dart';
import 'package:easy_attend/Widgets/PageOnMaintenance.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfDashboardMobile extends StatefulWidget {
  const ProfDashboardMobile({super.key});

  @override
  State<ProfDashboardMobile> createState() => _ProfDashboardMobileState();
}

class _ProfDashboardMobileState extends State<ProfDashboardMobile> {
  final BACKEND_URL = dotenv.env['API_URL'];
  bool dataIsLoaded = false;
  String imageUrl = "assets/admin.jpg"; // Default image
  late Map<String, dynamic> prof;
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  int nbreCours = 0;
  Set<dynamic> profFiliere = {};

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
    double screenWidth = MediaQuery.of(context).size.width;

    return !dataIsLoaded
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
                        'Bienvenue ${prof['nom']} ${prof['prenom']}',
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
                                            "Filières",
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
                              ),
                              SizedBox(
                                width: (screenWidth - 10) / 2,
                                height: 230,
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
                                            "Cours",
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
                              )
                            ],
                          )
                        ]),
                  ),
                ),
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
                            "Vos cours",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: FontSize.xxLarge,
                                fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            "Sélectionnez en un pour le gérer :",
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
                              style: const TextStyle(color: AppColors.white),
                              hint: const Text(
                                'Choisissez une filière pour trier',
                                style: TextStyle(color: AppColors.white),
                              ),
                              border: const BorderSide(
                                  color: AppColors.secondaryColor, width: 1),
                              dropdownColor: AppColors.secondaryColor,
                              dropdownButtonColor: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                              value: _selectedFiliere,
                              items: Allfilieres.map<DropdownMenuItem<Filiere>>(
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
                    height: 150, // Hauteur du conteneur principal
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
                              if (courses == null || courses.isEmpty) {
                                return Card(
                                  elevation: 8.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
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
                                            height: 120,
                                            width: 300,
                                            child: CourseCard(
                                              filiere: _selectedFiliere != null
                                                  ? _selectedFiliere!.nomFiliere
                                                  : Allfilieres.isEmpty
                                                      ? null
                                                      : Allfilieres.firstWhere(
                                                          (filiere) =>
                                                              filiere.idDoc ==
                                                              course[
                                                                  'idFiliere'],
                                                        ).nomFiliere,
                                              course: course,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OneCourseMobilePage(
                                                      course: course,
                                                      nomFiliere: Allfilieres
                                                          .firstWhere(
                                                        (filiere) =>
                                                            filiere.idDoc ==
                                                            course['idFiliere'],
                                                      ).nomFiliere,
                                                    ),
                                                  ),
                                                );
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              backgroundColor:
                                  AppColors.secondaryColor, // Couleur du bouton
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Bientôt disponible!',
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
          );
  }
}
