// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Screens/etudiant/seeMyAttendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/OneCoursePage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CourseCard extends StatefulWidget {
  String? name, filiere, niveau;
  String option;
  final course;
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
  //bool dataIsLoaded = false;

  // void loadProf() async {
  //   final prof =
  //       await get_Data().getProfById(widget.course['idProfesseur'], context);
  //   setState(() {
  //     professeur = prof;
  //     dataIsLoaded = true;
  //   });
  // }

  @override
  void initState() {
    //  loadProf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardPadding = screenWidth > 600 ? 22 : 12;
    double fontSizeTitle = screenWidth > 600 ? 17 : 10;
    double fontSizeSubTitle = screenWidth > 600 ? 15 : 8;

    return
        // !dataIsLoaded
        //     ? LoadingAnimationWidget.hexagonDots(
        //         color: AppColors.secondaryColor, size: 50)
        //     :
        InkWell(
      onTap: () {
        if (widget.option == "professeur" || widget.option == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OneCoursePage(course: widget.course)),
          );
        } else if (widget.option == "etudiant") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => seeMyAttendance(course: widget.course)),
          );
        }
      },
      child: Card(
        elevation: 5,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondaryColor, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                maxLines: 1,
                widget.name!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${widget.filiere ?? ""} ${widget.niveau}',
                style: TextStyle(
                  fontSize: fontSizeSubTitle,
                  color: Colors.white,
                ),
              ),
              // const SizedBox(height: 5),
              // Text(
              //   'Sigle: ${widget.course['sigleCours']}',
              //   style: TextStyle(
              //     fontSize: fontSizeSubTitle,
              //     color: Colors.white,
              //   ),
              // ),
              // const SizedBox(height: 5),
              // if ((widget.option == "admin" ||
              //         widget.option == "etudiant") &&
              //     professeur != null)
              //   Text(
              //     'Professeur : ${professeur['nom']} ${professeur['prenom']}',
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: fontSizeSubTitle,
              //       color: Colors.white,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
