// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:easy_attend/Config/styles.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatefulWidget {
  // const CourseCard({Key? key}) : super(key: key);

  String? name, filiere, teacher, niveau;
  String option;
  CourseCard(
      {required this.name,
      required this.niveau,
      this.filiere,
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
      width: 175,
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
              const SizedBox(height: 10.0),
              Text(
                widget.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15.0),
            ],
          ),
          onPressed: () {
            if (widget.option == "prof") {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => enrollStudent(dept:widget.dept,id:widget.id)),
              // );
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
