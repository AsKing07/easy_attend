import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeOneStudentAttendance.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class listOfStudentsOfACourse extends StatefulWidget {
  DocumentSnapshot<Object?> course;
  listOfStudentsOfACourse({required this.course});

  @override
  State<listOfStudentsOfACourse> createState() =>
      _listOfStudentsOfACourseState();
}

class _listOfStudentsOfACourseState extends State<listOfStudentsOfACourse> {
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
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('etudiant')
                .where('idFiliere', isEqualTo: widget.course['filiereId'])
                .where('niveau', isEqualTo: widget.course['niveau'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const NoResultWidget();
                } else {
                  final etudiants = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: etudiants.length,
                      itemBuilder: (context, index) {
                        final etudiant = etudiants[index];
                        final etudiantData =
                            etudiant.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                              '${etudiantData['nom']} ${etudiantData['prenom']}'),
                          subtitle: Text(
                            '${etudiantData['matricule']}',
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
                                          studentId: etudiant.id,
                                          studentName:
                                              '${etudiantData['nom']} ${etudiantData['prenom']}',
                                        )),
                              );
                            },
                          ),
                        );
                      });
                }
              } else if (snapshot.hasError) {
                return const NoResultWidget();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ))
        ],
      ),
    );
  }
}
