import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class seeOneStudentAttendance extends StatefulWidget {
  final String studentId, studentName;
  DocumentSnapshot<Object?> course;

  seeOneStudentAttendance(
      {required this.course,
      required this.studentId,
      required this.studentName});

  @override
  State<seeOneStudentAttendance> createState() =>
      _seeOneStudentAttendanceState();
}

class _seeOneStudentAttendanceState extends State<seeOneStudentAttendance> {
  @override
  void initState() {
    initializeDateFormatting('fr');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Présence de l\'étudiant'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('seance')
            .where('idCours', isEqualTo: widget.course.id)
            .orderBy('dateSeance', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const NoResultWidget();
          }

          List<DataRow> rows = [];
          snapshot.data!.docs.forEach((seance) {
            Map<String, dynamic> data = seance.data() as Map<String, dynamic>;
            String date = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
                .format(data['dateSeance'].toDate());
            bool statut = data['presenceEtudiant'][widget.studentId];

            rows.add(DataRow(cells: [
              DataCell(Text(date)),
              statut
                  ? const DataCell(Text(
                      'Présent(e)',
                      style: TextStyle(color: AppColors.greenColor),
                    ))
                  : const DataCell(Text(
                      'Absent(e)',
                      style: TextStyle(color: AppColors.redColor),
                    )),
            ]));
          });
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Text(
                    widget.course['nomCours'],
                    style: const TextStyle(
                      fontSize: FontSize.xLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.studentName,
                    style: const TextStyle(
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Date de la séance')),
                      DataColumn(label: Text('Statut')),
                    ],
                    rows: rows,
                  ),
                ],
              ));
        },
      ),
    );
  }
}
