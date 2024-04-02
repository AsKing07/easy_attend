import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';

class EtudiantDashboard extends StatefulWidget {
  const EtudiantDashboard({super.key});

  @override
  State<EtudiantDashboard> createState() => _EtudiantDashboardState();
}

class _EtudiantDashboardState extends State<EtudiantDashboard> {
  late DocumentSnapshot etudiant;
  // late DocumentSnapshot filiere;
  bool dataIsLoaded = false;
  List<Widget> myWidgets = [];

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

  // Future loadFiliere(String idFiliere) async {
  //   final x = await get_Data().getFiliereById(idFiliere, context);
  //   setState(() {
  //     filiere = x;
  //   });
  // }

  @override
  void initState() {
    loadStudent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !dataIsLoaded
            ? const Center(
                child: CircularProgressIndicator(),
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
                          stream: FirebaseFirestore.instance
                              .collection('cours')
                              .where('filiereId',
                                  isEqualTo: etudiant['idFiliere'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs
                                  .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                              {
                                return const NoResultWidget();
                              } else {
                                int length = snapshot.data!.docs.length;
                                var previous = null;
                                myWidgets.clear();
                                for (int i = 0; i < length; i++) {
                                  var object = snapshot.data!.docs[i];
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
                                              CourseId: previous.id,
                                            ),
                                            const SizedBox(
                                              width: 20.0,
                                            ),
                                            CourseCard(
                                              name: object['nomCours'],
                                              niveau: object['niveau'],
                                              filiere: etudiant['filiere'],
                                              option: "etudiant",
                                              CourseId: object.id,
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
                                  myWidgets.add(Row(children: [
                                    CourseCard(
                                      name: previous['nomCours'],
                                      niveau: previous['niveau'],
                                      filiere: etudiant['filiere'],
                                      option: "etudiant",
                                      CourseId: previous.id,
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                  ]));
                                }

                                return courseList(myWidgets);
                              }
                            } else {
                              return const Material(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          })
                    ],
                  ),
                ),
              ));
  }
}
