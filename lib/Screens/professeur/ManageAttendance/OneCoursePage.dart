// ignore_for_file: must_be_immutable, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/createSeance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfOneCourseSeance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/listOfStudentsOfACourse.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OneCoursePage extends StatefulWidget {
  final dynamic course;

  const OneCoursePage({super.key, required this.course});

  @override
  State<OneCoursePage> createState() => _OneCoursePageState();
}

class _OneCoursePageState extends State<OneCoursePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.course['nomCours']} - ${widget.course['niveau']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              "Que souhaitez-vous faire ?",
              style: GoogleFonts.poppins(
                  color: AppColors.textColor,
                  fontSize: FontSize.xxLarge,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${widget.course['nomCours']}  - ${widget.course['niveau']} ",
                style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: FontSize.medium,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(fixedSize: const Size(1000, 40)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateSeancePage(course: widget.course)),
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
                    ElevatedButton.styleFrom(fixedSize: const Size(1000, 40)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListOfOneCourseSeancePage(
                              course: widget.course,
                            )),
                  );
                },
                child: Text("Gérer les présences des séances",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.bold,
                    ))),
            const SizedBox(height: 16),
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(fixedSize: const Size(1000, 40)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            listOfStudentsOfACourse(course: widget.course)),
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
      )),
    );
  }
}
