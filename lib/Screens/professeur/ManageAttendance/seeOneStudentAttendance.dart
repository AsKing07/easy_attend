// ignore_for_file: use_build_context_synchronously, must_be_immutable, camel_case_types, file_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';

class seeOneStudentAttendance extends StatefulWidget {
  final String studentId, studentName;

  final dynamic course;

  const seeOneStudentAttendance(
      {super.key,
      required this.course,
      required this.studentId,
      required this.studentName});

  @override
  State<seeOneStudentAttendance> createState() =>
      _seeOneStudentAttendanceState();
}

class _seeOneStudentAttendanceState extends State<seeOneStudentAttendance> {
  int nombreTotalSeances = 0;
  int nombreDePresences = 0;
  double pourcentageDePresence = 0.0;
  final BACKEND_URL = dotenv.env['API_URL'];
  StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  late dynamic etudiant;
  StreamController<List<dynamic>> _createStreamController() {
    return StreamController<List<dynamic>>();
  }

  bool dataIsLoaded = false;

  Future<void> imprimerPdf() async {
    PDFHelper pdfHelper = PDFHelper();
    Uint8List pdfBytes = await pdfHelper.buildStudentPdf(widget.course,
        '${etudiant['nom']} ${etudiant['prenom']}', etudiant['uid'], context);
    await pdfHelper.savePdf(
        pdfBytes,
        '${widget.course['nomCours']}- ${widget.course['niveau']}- ${etudiant['nom']} ${etudiant['prenom']}',
        context);
  }

  Future fetchData() async {
    final x = await get_Data().loadCurrentStudentData();
    setState(() {
      etudiant = x;
      _streamController = _createStreamController();
    });
    try {
      http.Response response = await http.get(Uri.parse(
          '$BACKEND_URL/api/seance/getSeanceData?idCours=${widget.course['idCours']}'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        _streamController.add(seances);
        // print(seances);
        int count = 0;

        for (var seance in seances) {
          // Map<dynamic, dynamic> se = seance;
          Map<String, dynamic> presenceEtudiant =
              jsonDecode(seance['presenceEtudiant']);

          if (presenceEtudiant[widget.studentId] == true) {
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
        Helper().ErrorMessage(context,
            content: "Impossible de récupérer les informations du cours");
      }
    } catch (e) {
      // Gérer les erreurs ici
      !kReleaseMode
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Impossible de récupérer les informations du cours. Erreur:$e'),
                duration: const Duration(seconds: 6),
                backgroundColor: Colors.red,
              ),
            )
          : Helper().ErrorMessage(context,
              content: "Impossible de récupérer les informations du cours");
    }
  }

  @override
  void initState() {
    initializeDateFormatting('fr');
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Présence de l\'étudiant'),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.secondaryColor, size: 100));
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
                              DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
                                  .format(DateTime.parse(seance['dateSeance'])
                                      .toLocal()
                                      .subtract(const Duration(hours: 1)));

                          Map<String, dynamic> presenceEtudiant =
                              jsonDecode(seance['presenceEtudiant']);

                          bool statut =
                              presenceEtudiant[etudiant['uid']] ?? false;
                          attendanceData.add(
                            AttendanceData(date: date, statut: statut),
                          );
                        }
                        Map<String, double> dataMap = {
                          "Présence": nombreDePresences.toDouble(),
                          "Absence": (nombreTotalSeances - nombreDePresences)
                              .toDouble(),
                        };
                        final colorList = <Color>[
                          AppColors.greenColor,
                          AppColors.redColor
                        ];
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
                            //       Text("$nombreTotalSeances séance(s) au total"),
                            //       Text("$nombreDePresences présence(s)"),
                            //       Text(
                            //           "${nombreTotalSeances - nombreDePresences} absence(s)"),
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
                            //         fontWeight: FontWeight.bold, fontSize: 20.0),
                            //   ),
                            //   circularStrokeCap: CircularStrokeCap.butt,
                            //   backgroundColor: Colors.grey,
                            //   progressColor: AppColors.secondaryColor,
                            // ),

                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10.0,
                                  runSpacing: 10.0,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: !screenSize()
                                                  .isLargeScreen(context)
                                              ? (screenWidth - 10) / 2
                                              : (screenWidth - 10) / 4,
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
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize:
                                                          FontSize.xxLarge,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  AnimatedTextKit(
                                                      animatedTexts: [
                                                        TyperAnimatedText(
                                                          nombreTotalSeances
                                                              .toString(),
                                                          textStyle:
                                                              const TextStyle(
                                                            color: AppColors
                                                                .textColor,
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
                                          width: !screenSize()
                                                  .isLargeScreen(context)
                                              ? (screenWidth - 10) / 2
                                              : (screenWidth - 10) / 4,
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
                                                      color:
                                                          AppColors.textColor,
                                                      fontSize:
                                                          FontSize.xxLarge,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  AnimatedTextKit(
                                                      animatedTexts: [
                                                        TyperAnimatedText(
                                                          nombreDePresences
                                                              .toString(),
                                                          textStyle:
                                                              const TextStyle(
                                                            color: AppColors
                                                                .textColor,
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

                            const SizedBox(
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
                    ),
                  ],
                ),
              ));
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
  @override
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
