// ignore_for_file: camel_case_types, file_names, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeOneStudentAttendance.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class listOfStudentsOfACourse extends StatefulWidget {
  final dynamic course;
  const listOfStudentsOfACourse({super.key, required this.course});

  @override
  State<listOfStudentsOfACourse> createState() =>
      _listOfStudentsOfACourseState();
}

class _listOfStudentsOfACourseState extends State<listOfStudentsOfACourse> {
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  Future<void> fetchData() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/student/getStudentData?idFiliere=${widget.course['idFiliere']}&niveau=${widget.course['niveau']}'));

      if (response.statusCode == 200) {
        List<dynamic> students = jsonDecode(response.body);
        _streamController.add(students);
      } else {
        throw Exception('Erreur lors de la récupération des étudiants');
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les étudiants. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Liste des étudiants inscrits au cours ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              "Sélectionnez un étudiant dans la liste",
              style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: FontSize.medium,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
              child: StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.secondaryColor, size: 200));
              } else if (snapshot.hasError) {
                return Text('Erreur : ${snapshot.error}');
              } else {
                List<dynamic>? students = snapshot.data;
                if (students!
                    .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                {
                  return const SingleChildScrollView(
                    child: NoResultWidget(),
                  );
                } else {
                  return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final etudiant = students[index];

                        return ListTile(
                          title:
                              Text('${etudiant['nom']} ${etudiant['prenom']}'),
                          subtitle: Text(
                            '${etudiant['matricule']}',
                            style: const TextStyle(
                                color: AppColors.secondaryColor,
                                fontSize: FontSize.small),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_red_eye_sharp),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        seeOneStudentAttendance(
                                          course: widget.course,
                                          studentId: etudiant['uid'],
                                          studentName:
                                              '${etudiant['nom']} ${etudiant['prenom']}',
                                        )),
                              );
                            },
                          ),
                        );
                      });
                }
              }
            },
          ))
        ],
      ),
    );
  }
}
