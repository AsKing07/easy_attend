// ignore_for_file: use_build_context_synchronously, camel_case_types, must_be_immutable, file_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';

class seeMyAttendance extends StatefulWidget {
  DocumentSnapshot course;

  seeMyAttendance({super.key, required this.course});

  @override
  State<seeMyAttendance> createState() => _seeOneStudentAttendanceState();
}

class _seeOneStudentAttendanceState extends State<seeMyAttendance> {
  late DocumentSnapshot etudiant;
  late DocumentSnapshot course;
  bool dataIsLoaded = false;
  int nombreTotalSeances = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;

  void loadStudent() async {
    final x = await get_Data().loadCurrentStudentData();
    await loadCourse();
    setState(() {
      etudiant = x;
      dataIsLoaded = true;
    });
  }

  Future loadCourse() async {
    final x = await get_Data().getCourseById(widget.course.id, context);
    setState(() {
      course = x;
    });
  }

  @override
  void initState() {
    loadStudent();
    initializeDateFormatting('fr');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Présence'),
      ),
      body: !dataIsLoaded
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('seance')
                  .where('idCours', isEqualTo: course.id)
                  .orderBy('dateSeance', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.secondaryColor, size: 200),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const NoResultWidget();
                }

                nombreTotalSeances = snapshot.data!.docs.length;
                nombreDePresences = snapshot.data!.docs.where((seance) {
                  Map<String, dynamic> data =
                      seance.data() as Map<String, dynamic>;
                  // Vérifiez si la valeur n'est pas nulle et convertissez-la en booléen
                  return (data['presenceEtudiant'][etudiant.id] ?? false) ==
                      true;
                }).length;

                pourcentageDePresence =
                    (nombreDePresences / nombreTotalSeances);

                List<DataRow> rows = [];
                for (var seance in snapshot.data!.docs) {
                  Map<String, dynamic> data =
                      seance.data() as Map<String, dynamic>;
                  String date = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
                      .format(data['dateSeance'].toDate());

                  bool statut = data['presenceEtudiant'][etudiant.id] ?? false;

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
                }
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    Text(
                      course['nomCours'],
                      style: const TextStyle(
                        fontSize: FontSize.xLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '${etudiant['nom']} ${etudiant['prenom']}',
                      style: const TextStyle(
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    CircularPercentIndicator(
                      radius: 130.0,
                      animation: true,
                      animationDuration: 1200,
                      lineWidth: 15.0,
                      percent: pourcentageDePresence,
                      center: Text(
                        '${pourcentageDePresence * 100}% de présence',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.butt,
                      backgroundColor: Colors.grey,
                      progressColor: AppColors.secondaryColor,
                    ),
                    const SizedBox(height: 15),
                    IconButton(
                        iconSize: 50,
                        onPressed: () async {
                          PDFHelper pdfHelper = PDFHelper();
                          Uint8List pdfBytes = await pdfHelper.buildStudentPdf(
                              widget.course,
                              '${etudiant['nom']} ${etudiant['prenom']}',
                              etudiant.id,
                              context);
                          await pdfHelper.savePdf(
                              pdfBytes,
                              '${widget.course['nomCours']}- ${widget.course['niveau']}- ${etudiant['nom']} ${etudiant['prenom']}',
                              context);
                        },
                        icon: const Icon(Icons.print,
                            color: AppColors.secondaryColor)),
                    const Text("Imprimer"),
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
