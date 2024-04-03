// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SeeSeanceAttendanceProf extends StatefulWidget {
  final String seanceId;
  final DocumentSnapshot course;

  const SeeSeanceAttendanceProf(
      {Key? key, required this.seanceId, required this.course})
      : super(key: key);

  @override
  State<SeeSeanceAttendanceProf> createState() =>
      _SeeSeanceAttendanceProfState();
}

class _SeeSeanceAttendanceProfState extends State<SeeSeanceAttendanceProf> {
  int nombreTotalEtudiants = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Présence de la séance ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Resultat de la présence',
              style: TextStyle(
                fontSize: FontSize.xLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('seance')
                    .doc(widget.seanceId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Une erreur s\'est produite'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const NoResultWidget();
                  }

                  DocumentSnapshot seance = snapshot.data!;
                  Map<String, dynamic>? presenceEtudiants =
                      snapshot.data!.get('presenceEtudiant');
                  String date =
                      'Séance du ${DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(snapshot.data!.get('dateSeance').toDate())}';

                  if (presenceEtudiants == null || presenceEtudiants.isEmpty) {
                    return const Center(
                        child: Text(
                            'Aucune présence enregistrée pour cette séance'));
                  }
                  nombreTotalEtudiants = presenceEtudiants.length;
                  nombreDePresences = presenceEtudiants.values
                      .where((present) => present)
                      .length;
                  pourcentageDePresence =
                      (nombreDePresences / nombreTotalEtudiants);
                  List<DataRow> rows = [];
                  presenceEtudiants.forEach((etudiantId, present) {
                    rows.add(DataRow(
                      cells: [
                        DataCell(FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('etudiant')
                                .doc(etudiantId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Chargement...');
                              }
                              if (snapshot.hasError) {
                                return Text('Erreur: ${snapshot.error}');
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text('Etudiant introuvable');
                              }
                              String nom = snapshot.data!.get('nom');
                              String prenom = snapshot.data!.get('prenom');

                              return Text('$nom $prenom');
                            })),
                        present
                            ? const DataCell(Text(
                                'Présent(e)',
                                style: TextStyle(color: AppColors.greenColor),
                              ))
                            : const DataCell(Text(
                                'Absent(e)',
                                style: TextStyle(color: AppColors.redColor),
                              )),
                      ],
                    ));
                  });
                  return Column(
                    children: [
                      Text(date),
                      const SizedBox(
                        height: 10,
                      ),
                      CircularPercentIndicator(
                        footer:
                            Text("$nombreTotalEtudiants Etudiants au total"),
                        radius: 130.0,
                        animation: true,
                        animationDuration: 1200,
                        lineWidth: 15.0,
                        percent: pourcentageDePresence,
                        center: Text(
                          '${(pourcentageDePresence * 100).toString().substring(0, 5)}% de présence',
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
                            Uint8List pdfBytes =
                                await pdfHelper.buildGeneralPdf(
                                    seance, widget.course, context);
                            await pdfHelper.savePdf(
                                pdfBytes,
                                '${widget.course['nomCours']}- ${widget.course['niveau']}- ${DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(seance['dateSeance'].toDate())}',
                                context);
                          },
                          icon: const Icon(Icons.print,
                              color: AppColors.secondaryColor)),
                      const Text("Imprimer"),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nom')),
                            DataColumn(label: Text('Présence')),
                          ],
                          rows: rows,
                        ),
                      )
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
