// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/etudiant/seeMyAttendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/OneCoursePage.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatefulWidget {
  String? name, filiere, niveau;
  String option;
  DocumentSnapshot course;
  CourseCard(
      {required this.name,
      required this.niveau,
      this.filiere,
      required this.course,
      required this.option});
  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      width: 140,
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
                        fontSize: 18.0,
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
