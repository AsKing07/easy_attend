// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/OneCoursePage.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatefulWidget {
  String? name, filiere, teacher, niveau;
  String option, CourseId;
  CourseCard(
      {required this.name,
      required this.niveau,
      this.filiere,
      required this.CourseId,
      required this.teacher,
      required this.option});
  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      width: 160,
      height: 175,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: TextButton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.filiere} ${widget.niveau}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
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
              const SizedBox(height: 15.0),
            ],
          ),
          onPressed: () {
            if (widget.option == "professeur") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OneCoursePage(CourseId: widget.CourseId)),
              );
            } else if (widget.option == "etudiant") {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context)=> showAttendance(course:widget.dept+' '+widget.id)),
              // );
            }
          },
        ),
      ),
    );
  }
}
