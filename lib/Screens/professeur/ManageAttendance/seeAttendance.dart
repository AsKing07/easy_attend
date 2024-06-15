// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';

class SeeSeanceAttendanceProf extends StatefulWidget {
  final dynamic seance;
  final dynamic course;
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
  Map<String, double> dataMap = {};
  bool dataIsLoading = true;
  late Map<String, dynamic> presenceEtudiants;
  String date = '';
  final BACKEND_URL = dotenv.env['API_URL'];

  late dynamic etudiant;
  dynamic seance;
  StreamController<List<dynamic>> _createStreamController() {
    return StreamController<List<dynamic>>();
  }

  Future<void> imprimerPdf() async {
    PDFHelper pdfHelper = PDFHelper();
    Uint8List pdfBytes = await pdfHelper.buildStudentPdf(widget.course,
        '${etudiant['nom']} ${etudiant['prenom']}', etudiant['uid'], context);
    await pdfHelper.savePdf(
        pdfBytes,
        '${widget.course['nomCours']}- ${widget.course['niveau']}- ${etudiant['nom']} ${etudiant['prenom']}',
        context);
  }

  List<DataRow> rows = [];
  List<AttendanceData> attendanceData = [];
  final colorList = <Color>[AppColors.greenColor, AppColors.redColor];
  Future<void> fetchData() async {
    setState(() {
      dataIsLoading = true;
    });
    dynamic se =
        await get_Data().getSeanceByCode(widget.seance['seanceCode'], context);

    setState(() {
      date =
          'Séance du ${DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr').format(DateTime.parse(widget.seance['dateSeance']).toLocal().subtract(Duration(hours: 1))).toUpperCase()}  ';
      presenceEtudiants = jsonDecode(se['presenceEtudiant']);
      nombreTotalEtudiants = presenceEtudiants.length;
      nombreDePresences =
          presenceEtudiants.values.where((present) => present).length;
      pourcentageDePresence = (nombreDePresences / nombreTotalEtudiants);
    });
    attendanceData.clear();
    // Fetch les données des étudiants et met à jour la liste des rows
    for (var entry in presenceEtudiants.entries) {
      final etudiantId = entry.key;
      final present = entry.value;
      final etudiantData = await fetchStudent(etudiantId);
      if (etudiantData != null) {
        final nom = etudiantData['nom'];
        final prenom = etudiantData['prenom'];
        attendanceData.add(
          AttendanceData(
              nom: '$nom $prenom',
              statut: present,
              matricule: etudiantData['matricule']),
        );

        //   setState(() {
        //     rows.add(DataRow(cells: [
        //       DataCell(Text('$nom $prenom')),
        //       DataCell(
        //         Text(
        //           present ? 'Présent(e)' : 'Absent(e)',
        //           style: TextStyle(
        //               color: present ? AppColors.greenColor : AppColors.redColor),
        //         ),
        //       )
        //     ]));
        //   });
      }
    }
    setState(() {
      dataMap = {
        "Présence": nombreDePresences.toDouble(),
        "Absence": (nombreTotalEtudiants - nombreDePresences).toDouble(),
      };
      dataIsLoading = false;
    });
  }

  Future fetchStudent(id) async {
    final response = await http
        .get(Uri.parse('$BACKEND_URL/api/student/getStudentById/$id'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    }
    // throw Exception('Failed to load student');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return dataIsLoading
        ? Container(
            decoration: const BoxDecoration(color: AppColors.white),
            child: Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              title: Text(
                'Séance de ${widget.course['nomCours']} ',
                style: const TextStyle(
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
                  (presenceEtudiants.isEmpty)
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
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.xxLarge)),
                            const SizedBox(
                              height: 10,
                            ),
                            PieChart(
                              dataMap: dataMap,
                              chartType: ChartType.disc,
                              chartRadius: 150,
                              baseChartColor:
                                  Colors.grey[50]!.withOpacity(0.15),
                              colorList: colorList,
                              chartValuesOptions: const ChartValuesOptions(
                                showChartValuesInPercentage: true,
                                // showChartValuesOutside: true,
                              ),
                              //totalValue: nombreTotalSeances.toDouble(),
                            ),
                            // CircularPercentIndicator(
                            //   footer: Column(
                            //     children: [
                            //       Text(
                            //           "$nombreTotalEtudiants Etudiants au total"),
                            //       Text("$nombreDePresences présent(s)"),
                            //       Text(
                            //           "${nombreTotalEtudiants - nombreDePresences} absent(s)"),
                            //     ],
                            //   ),
                            //   radius: 130.0,
                            //   animation: true,
                            //   animationDuration: 1200,
                            //   lineWidth: 15.0,
                            //   percent: pourcentageDePresence,
                            //   center: Text(
                            //     '${(pourcentageDePresence * 100).toStringAsFixed(2)}% de présence',
                            //     style: const TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 20.0),
                            //   ),
                            //   circularStrokeCap: CircularStrokeCap.butt,
                            //   backgroundColor: Colors.grey,
                            //   progressColor: AppColors.secondaryColor,
                            // ),
                            const SizedBox(height: 15),
                            // IconButton(
                            //     iconSize: 50,
                            //     onPressed: () async {
                            //       PDFHelper pdfHelper = PDFHelper();
                            //       Uint8List pdfBytes =
                            //           await pdfHelper.buildGeneralPdf(
                            //               widget.seance,
                            //               widget.course,
                            //               context);
                            //       await pdfHelper.savePdf(
                            //           pdfBytes,
                            //           '${widget.course['nomCours']}- ${widget.course['niveau']}- $date',
                            //           context);
                            //     },
                            //     icon: const Icon(Icons.print,
                            //         color: AppColors.secondaryColor)),
                            // const Text("Imprimer"),
                            // const SizedBox(height: 15),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: AttendancePaginatedTable(
                                key: ValueKey(attendanceData),
                                attendanceData: attendanceData,
                                callback: fetchData,
                                imprimPdf: imprimerPdf,
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

class AttendanceData {
  final String matricule;
  final String nom;
  final bool statut;

  AttendanceData(
      {required this.matricule, required this.statut, required this.nom});
}

class AttendanceDataSource extends DataTableSource {
  final List<AttendanceData> attendanceData;
  final Set<int> _selectedRows = {};

  AttendanceDataSource({required this.attendanceData});

  Color _getRowColor(int index) {
    return _selectedRows.contains(index) ? Colors.green : Colors.grey[200]!;
  }

  @override
  DataRow getRow(int index) {
    final attendance = attendanceData[index];
    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        _handleRowSelected(selected, index);
      },
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        return _getRowColor(index);
      }),
      cells: [
        DataCell(Text(attendance.matricule.toUpperCase())),
        DataCell(Text(attendance.nom.toUpperCase())),
        DataCell(
          attendance.statut
              ? const Icon(Icons.check, color: AppColors.greenColor)
              : const Icon(Icons.close, color: AppColors.redColor),
        ),
      ],
    );
  }

  void _handleRowSelected(bool? selected, int rowIndex) {
    if (selected!) {
      _selectedRows.add(rowIndex);
    } else {
      _selectedRows.remove(rowIndex);
    }
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => attendanceData.length;

  @override
  int get selectedRowCount => _selectedRows.length;
}

class AttendancePaginatedTable extends StatefulWidget {
  final List<AttendanceData> attendanceData;
  final Function()? callback;
  final Function()? imprimPdf;
  const AttendancePaginatedTable(
      {Key? key, required this.attendanceData, this.callback, this.imprimPdf})
      : super(key: key);
  State<AttendancePaginatedTable> createState() =>
      _AttendancePaginatedTableState();
}

class _AttendancePaginatedTableState extends State<AttendancePaginatedTable> {
  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      actions: <IconButton>[
        IconButton(
          color: Colors.blue,
          splashColor: Colors.transparent,
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            //I want to refresh data from the fetchData method in seeMyAttendClass
            await widget.callback!();
          },
        ),
        IconButton(
            color: Colors.black,
            onPressed: () async {
              await widget.imprimPdf!();
            },
            icon: const Icon(Icons.print))
      ],
      header: const Text(
        'Liste de présence',
        textAlign: TextAlign.center,
      ),
      columns: const [
        DataColumn(
          label: Text(
            'Matricule',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Nom',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Présence',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      source: AttendanceDataSource(attendanceData: widget.attendanceData),
      rowsPerPage: 7,
      columnSpacing: 10,
      horizontalMargin: 10,
      showCheckboxColumn: true,
      showFirstLastButtons: true,
      showEmptyRows: false,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black),
    );
  }
}
