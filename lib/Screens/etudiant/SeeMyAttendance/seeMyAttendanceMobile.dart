// ignore_for_file: use_build_context_synchronously, camel_case_types, must_be_immutable, file_names, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;

class seeMyAttendanceMobilePage extends StatefulWidget {
  final dynamic course;

  const seeMyAttendanceMobilePage({super.key, required this.course});

  @override
  State<seeMyAttendanceMobilePage> createState() =>
      _seeMyAttendanceMobilePageState();
}

class _seeMyAttendanceMobilePageState extends State<seeMyAttendanceMobilePage> {
  late dynamic etudiant;

  bool dataIsLoaded = false;
  int nombreTotalSeances = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;

  final BACKEND_URL = dotenv.env['API_URL'];
  StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

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

  Future<void> fetchData() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      _streamController = _createStreamController();
    });

    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/seance/getSeanceData?idCours=${widget.course['idCours']}'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        _streamController.add(seances);

        int count = 0;
        for (var seance in seances) {
          // Map<dynamic, dynamic> se = seance;
          Map<String, dynamic> presenceEtudiant =
              jsonDecode(seance['presenceEtudiant']);

          if (presenceEtudiant[etudiant['uid']] == true) {
            count++;
          }
        }

        setState(() {
          nombreTotalSeances = seances.length;

          nombreDePresences = count;
          pourcentageDePresence = (nombreDePresences / nombreTotalSeances);
          dataIsLoaded = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer les informations du cours.'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: kReleaseMode
              ? const Text('Impossible de récupérer les informations du cours.')
              : Text(
                  'Impossible de récupérer les informations du cours. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Présence'),
      ),
      body: !dataIsLoaded
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            )
          : SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.hexagonDots(
                              color: AppColors.secondaryColor, size: 100),
                        );
                      }
                      if (snapshot.hasError) {
                        return errorWidget(error: snapshot.error.toString());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const NoResultWidget();
                      }

                      List<AttendanceData> attendanceData = [];
                      for (var seance in snapshot.data!) {
                        String date =
                            DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr').format(
                                DateTime.parse(seance['dateSeance']).toLocal());

                        Map<String, dynamic> presenceEtudiant =
                            jsonDecode(seance['presenceEtudiant']);

                        bool statut =
                            presenceEtudiant[etudiant['uid']] ?? false;
                        attendanceData.add(
                          AttendanceData(date: date, statut: statut),
                        );
                      }
                      return Column(
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
                          CircularPercentIndicator(
                            radius: 90.0,
                            animation: true,
                            animationDuration: 1200,
                            lineWidth: 15.0,
                            percent: pourcentageDePresence,
                            center: Text(
                              '${(pourcentageDePresence * 100).toStringAsFixed(2)}% de présence',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.butt,
                            backgroundColor: Colors.grey,
                            progressColor: AppColors.secondaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10.0,
                                runSpacing: 10.0,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: (screenWidth - 10) / 2,
                                        height: 100,
                                        child: Card(
                                          color: Colors.white,
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Séances",
                                                  style: TextStyle(
                                                    color: AppColors.textColor,
                                                    fontSize: FontSize.xxLarge,
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                AnimatedTextKit(animatedTexts: [
                                                  TyperAnimatedText(
                                                    nombreTotalSeances
                                                        .toString(),
                                                    textStyle: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize: 25.0,
                                                    ),
                                                    speed: const Duration(
                                                        milliseconds:
                                                            100), // Vitesse de l'animation
                                                  ),
                                                ])
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: (screenWidth - 10) / 2,
                                        height: 100,
                                        child: Card(
                                          color: Colors.white,
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Présences",
                                                  style: TextStyle(
                                                    color: AppColors.textColor,
                                                    fontSize: FontSize.xxLarge,
                                                  ),
                                                ),
                                                const SizedBox(height: 10.0),
                                                AnimatedTextKit(animatedTexts: [
                                                  TyperAnimatedText(
                                                    nombreDePresences
                                                        .toString(),
                                                    textStyle: const TextStyle(
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize: 25.0,
                                                    ),
                                                    speed: const Duration(
                                                        milliseconds:
                                                            100), // Vitesse de l'animation
                                                  ),
                                                ])
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: AttendancePaginatedTable(
                              key: ValueKey(attendanceData),
                              attendanceData: attendanceData,
                              callback: fetchData,
                              imprimPdf: imprimerPdf,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ])),
    );
  }
}

class AttendanceData {
  final String date;
  final bool statut;

  AttendanceData({required this.date, required this.statut});
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
        DataCell(Text(attendance.date.toUpperCase())),
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
      header: Text('Liste de présence'),
      columns: const [
        DataColumn(
          label: Text(
            'Date de la séance',
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
