// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:easy_attend/Config/styles.dart';

class CourseCard extends StatefulWidget {
  String? filiere;

  final course;
  final VoidCallback onTap;
  CourseCard(
      {super.key, this.filiere, required this.course, required this.onTap});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  void initState() {
    //  loadProf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardPadding = screenWidth > 1200 ? 22 : 10;
    double fontSizeTitle = screenWidth > 1200 ? 17 : 15;
    double fontSizeSubTitle = screenWidth > 1200 ? 15 : 10;

    return
        // !dataIsLoaded
        //     ? LoadingAnimationWidget.hexagonDots(
        //         color: AppColors.secondaryColor, size: 50)
        //     :
        InkWell(
      onTap: () {
        widget.onTap();
        //   if (widget.option == "professeur" || widget.option == 'admin') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => OneCoursePage(course: widget.course)),
        //   );
        // }
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
                "${widget.course['nomCours']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeTitle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                'Filière: ${widget.filiere ?? ""}',
                style: TextStyle(
                  fontSize: fontSizeSubTitle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Année: ${widget.course['niveau']} ',
                style: TextStyle(
                  fontSize: fontSizeSubTitle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Sigle: ${widget.course['sigleCours']}',
                style: TextStyle(
                  fontSize: fontSizeSubTitle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
