import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

class SeeSeanceAttendanceProf extends StatefulWidget {
  final seance;
  final course;
  const SeeSeanceAttendanceProf(
      {Key? key, required this.seance, required this.course})
      : super(key: key);
  @override
  State<SeeSeanceAttendanceProf> createState() =>
      _SeeSeanceAttendanceProfState();
}

class _SeeSeanceAttendanceProfState extends State<SeeSeanceAttendanceProf> {
  int nombreTotalEtudiants = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;
  bool dataIsLoading = true;
  late Map<String, dynamic> presenceEtudiants;
  String date = '';
  final BACKEND_URL = dotenv.env['API_URL'];

  List<DataRow> rows = [];

  Future<void> fetchData() async {
    setState(() {
      date =
          'Séance du ${DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(DateTime.parse(widget.seance['dateSeance']).toLocal()).toUpperCase()}  ';
      presenceEtudiants = jsonDecode(widget.seance['presenceEtudiant']);
      nombreTotalEtudiants = presenceEtudiants.length;
      nombreDePresences =
          presenceEtudiants.values.where((present) => present).length;
      pourcentageDePresence = (nombreDePresences / nombreTotalEtudiants);
    });

    // Fetch les données des étudiants et met à jour la liste des rows
    for (var entry in presenceEtudiants.entries) {
      final etudiantId = entry.key;
      final present = entry.value;
      final etudiantData = await fetchStudent(etudiantId);
      if (etudiantData != null) {
        final nom = etudiantData['nom'];
        final prenom = etudiantData['prenom'];
        setState(() {
          rows.add(DataRow(cells: [
            DataCell(Text('$nom $prenom')),
            DataCell(
              Text(
                present ? 'Présent(e)' : 'Absent(e)',
                style: TextStyle(
                    color: present ? AppColors.greenColor : AppColors.redColor),
              ),
            )
          ]));
        });
      }
    }

    setState(() {
      dataIsLoading = false;
    });
  }

  Future fetchStudent(id) async {
    final response =
        await http.get(Uri.parse('$BACKEND_URL/api/global/getStudentById/$id'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    }
    throw Exception('Failed to load student');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return dataIsLoading
        ? Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.secondaryColor, size: 100),
          )
        : Scaffold(
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
                  (presenceEtudiants == null || presenceEtudiants.isEmpty)
                      ? const Center(
                          child: Text(
                          'Aucune présence enregistrée pour cette séance',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: FontSize.xxLarge),
                        ))
                      : Column(
                          children: [
                            Text(date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.xxLarge)),
                            const SizedBox(
                              height: 10,
                            ),
                            CircularPercentIndicator(
                              footer: Column(
                                children: [
                                  Text(
                                      "$nombreTotalEtudiants Etudiants au total"),
                                  Text("$nombreDePresences présent(s)"),
                                  Text(
                                      "${nombreTotalEtudiants - nombreDePresences} absent(s)"),
                                ],
                              ),
                              radius: 130.0,
                              animation: true,
                              animationDuration: 1200,
                              lineWidth: 15.0,
                              percent: pourcentageDePresence,
                              center: Text(
                                '${(pourcentageDePresence * 100).toStringAsFixed(2)}% de présence',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
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
                                          widget.seance,
                                          widget.course,
                                          context);
                                  await pdfHelper.savePdf(
                                      pdfBytes,
                                      '${widget.course['nomCours']}- ${widget.course['niveau']}- ${date}',
                                      context);
                                },
                                icon: const Icon(Icons.print,
                                    color: AppColors.secondaryColor)),
                            const Text("Imprimer"),
                            const SizedBox(height: 15),
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
                        ),
                ],
              ),
            ),
          );
  }
}
