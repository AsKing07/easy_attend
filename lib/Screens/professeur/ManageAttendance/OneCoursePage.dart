import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/createSeance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfOneCourseSeance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfStudentsOfACourse.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OneCoursePage extends StatefulWidget {
  String CourseId;

  OneCoursePage({required this.CourseId});

  @override
  State<OneCoursePage> createState() => _OneCoursePageState();
}

class _OneCoursePageState extends State<OneCoursePage> {
  bool dataIsloaded = false;
  late DocumentSnapshot course;
  Future loadCourseData() async {
    course = await get_Data().getCourseById(widget.CourseId, context);

    setState(() {
      dataIsloaded = true;
    });
  }

  @override
  void initState() {
    loadCourseData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !dataIsloaded
        ? const SizedBox()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              title: Text(
                '${course['nomCours']} - ${course['niveau']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.medium,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Que souhaitez-vous faire",
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      "${course['nomCours']}  - ${course['niveau']} ",
                      style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(fixedSize: Size(1000, 40)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CreateSeancePage(Courseid: widget.CourseId)),
                        );
                      },
                      child: Text("Démarrer une nouvelle séance",
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.bold,
                          ))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(fixedSize: Size(1000, 40)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListOfOneCourseSeancePage(
                                    CourseId: widget.CourseId,
                                  )),
                        );
                      },
                      child: Text("Gérer les présences des séances",
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.bold,
                          ))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(fixedSize: Size(1000, 40)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  listOfStudentsOfACourse(course: course)),
                        );
                      },
                      child: Text(
                        "Consulter la présence d'un seul étudiant",
                        style: GoogleFonts.poppins(
                          color: AppColors.secondaryColor,
                          fontSize: FontSize.small,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
            ));
  }
}
