// ignore_for_file: file_names, camel_case_types, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Widgets/courseCard.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class listOfCourse extends StatefulWidget {
  const listOfCourse({super.key});

  @override
  State<listOfCourse> createState() => _listOfCourseState();
}

class _listOfCourseState extends State<listOfCourse> {
  bool dataIsLoaded = false;
  List<Widget> myWidgets = [];
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;

  Widget courseList(List<Widget> myWidget) {
    return Column(
      children: [for (var w in myWidget) w],
    );
  }

  Future<void> loadAllActifFilieres() async {
    List<QueryDocumentSnapshot> docsFiliere =
        await get_Data().getActifFiliereData();
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      Filiere filiere = Filiere(
        idDoc: doc.id,
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["idFiliere"],
        statut: doc["statut"],
        niveaux: List<String>.from(
          doc['niveaux'],
        ),
      );

      fil.add(filiere);
    }

    setState(() {
      Allfilieres.addAll(fil);
      dataIsLoaded = true;
    });
  }

  @override
  void initState() {
    loadAllActifFilieres();
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
                    const Text(
                      'Sélectionnez un cours pour consulter la présence',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    //Dropdown Filieres
                    DropdownButtonFormField<Filiere>(
                      value: _selectedFiliere,
                      elevation: 18,
                      onChanged: (Filiere? value) {
                        setState(() {
                          _selectedFiliere = value!;
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
                                'Sélectionnez une filière pour afficher les cours de la filière uniquement'),
                          )
                        : StreamBuilder(
                            stream: _selectedFiliere == null
                                ? FirebaseFirestore.instance
                                    .collection('cours')
                                    .snapshots()
                                : FirebaseFirestore.instance
                                    .collection('cours')
                                    .where('filiereId',
                                        isEqualTo: _selectedFiliere?.idDoc)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int length = snapshot.data!.docs.length;
                                var previous;
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
                                              filiere:
                                                  _selectedFiliere?.idFiliere,
                                              option: "admin",
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
                                              option: "admin",
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
                                          option: "admin",
                                          course: previous,
                                        ),
                                      ]));
                                }

                                return courseList(myWidgets);
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
