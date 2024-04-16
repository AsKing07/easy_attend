// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, must_be_immutable, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/etudiant/seeMyAttendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/OneCoursePage.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CourseCard extends StatefulWidget {
  String? name, filiere, niveau;
  String option;
  DocumentSnapshot course;
  CourseCard(
      {super.key,
      required this.name,
      required this.niveau,
      this.filiere,
      required this.course,
      required this.option});
  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  var professeur;
  bool dataIsLoaded = false;
  void loadProf() async {
    DocumentSnapshot prof =
        await get_Data().getProfById(widget.course['professeurId'], context);

    setState(() {
      professeur = prof;
      dataIsLoaded = true;
    });
  }

  @override
  void initState() {
    loadProf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !dataIsLoaded
        ? LoadingAnimationWidget.hexagonDots(
            color: AppColors.secondaryColor, size: 50)
        : Container(
            margin: const EdgeInsets.only(top: 5.0),
            width: MediaQuery.of(context).size.width > 400 ? 200 : 150,
            height: widget.option == "admin" ? 230 : 170,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: TextButton(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.option == "etudiant"
                        ? Text(
                            ' ${widget.niveau}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '${widget.filiere} ${widget.niveau}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.course['idCours'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    widget.option == "admin"
                        ? Text(
                            'Professeur : \n ${professeur['nom']} ${professeur['prenom']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
                onPressed: () {
                  if (widget.option == "professeur" ||
                      widget.option == 'admin') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OneCoursePage(course: widget.course)),
                    );
                  } else if (widget.option == "etudiant") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              seeMyAttendance(course: widget.course)),
                    );
                  }
                },
              ),
            ),
          );
  }
}
