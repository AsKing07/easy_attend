// ignore_for_file: use_build_context_synchronously, camel_case_types, must_be_immutable, file_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;

class seeMyAttendance extends StatefulWidget {
  final course;

  seeMyAttendance({super.key, required this.course});

  @override
  State<seeMyAttendance> createState() => _seeOneStudentAttendanceState();
}

class _seeOneStudentAttendanceState extends State<seeMyAttendance> {
  late final etudiant;

  bool dataIsLoaded = false;
  int nombreTotalSeances = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;

  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  Future<void> fetchData() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      dataIsLoaded = true;
    });

    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/seance/getSeanceData?idCours=${widget.course['idCours']}'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        _streamController.add(seances);
        print(seances);
        int count = 0;
        seances.forEach((seance) {
          // Map<dynamic, dynamic> se = seance;
          Map<String, dynamic> presenceEtudiant =
              jsonDecode(seance['presenceEtudiant']);

          if (presenceEtudiant[etudiant['uid']] == true) {
            count++;
          }
        });
        print(count);
        setState(() {
          nombreTotalSeances = seances.length;

          nombreDePresences = count;
          pourcentageDePresence = (nombreDePresences / nombreTotalSeances);
        });
      } else {
        throw Exception('Erreur lors de la récupération des seances');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }

  @override
  void initState() {
    fetchData();
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
          : StreamBuilder(
              stream: _streamController.stream,
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

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const NoResultWidget();
                }

                List<DataRow> rows = [];
                for (var seance in snapshot.data!) {
                  String date = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
                      .format(DateTime.parse(seance['dateSeance']).toLocal());

                  Map<String, dynamic> presenceEtudiant =
                      jsonDecode(seance['presenceEtudiant']);
                  bool statut = presenceEtudiant[etudiant['uid']];
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
                              etudiant['uid'],
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
