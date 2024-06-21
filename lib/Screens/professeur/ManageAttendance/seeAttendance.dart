// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/pdfHelper.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

  Future<void> imprimerPdf() async {
    PDFHelper pdfHelper = PDFHelper();
    Uint8List pdfBytes = await pdfHelper.buildStudentPdf(widget.course,
        '${etudiant['nom']} ${etudiant['prenom']}', etudiant['uid'], context);
    await pdfHelper.savePdf(
        pdfBytes,
        '${widget.course['nomCours']}- ${widget.course['niveau']}- ${etudiant['nom']} ${etudiant['prenom']}',
        context);
  }

  List<AttendanceData> attendanceData = [];
  final colorList = <Color>[AppColors.greenColor, AppColors.redColor];
  Future<void> fetchData() async {
    try {
      setState(() {
        dataIsLoading = true;
      });
      dynamic se = await get_Data()
          .getSeanceByCode(widget.seance['seanceCode'], context);

      setState(() {
        date =
            'Séance du ${DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr').format(DateTime.parse(widget.seance['dateSeance']).toLocal().subtract(const Duration(hours: 1))).toUpperCase()}  ';
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
        }
      }
      setState(() {
        dataMap = {
          "Présence": nombreDePresences.toDouble(),
          "Absence": (nombreTotalEtudiants - nombreDePresences).toDouble(),
        };
        dataIsLoading = false;
      });
    } catch (e) {
      kReleaseMode
          ? Helper().ErrorMessage(context)
          : Helper().ErrorMessage(context, content: "$e");
    }
  }

  Future fetchStudent(id) async {
    final response = await http
        .get(Uri.parse('$BACKEND_URL/api/student/getStudentById/$id'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      Helper().ErrorMessage(context,
          content: "Impossible de récupérer l'étudiant avec l'id : $id");
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
                            const SizedBox(height: 15),
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

// Classe représentant les données de présence
class AttendanceData {
  final String matricule;
  final String nom;
  final bool statut;

  AttendanceData({
    required this.matricule,
    required this.statut,
    required this.nom,
  });
}

// Classe représentant la source des données pour le DataTable
class AttendanceDataSource extends DataTableSource {
  List<AttendanceData> attendanceData;
  List<AttendanceData> filteredData;
  final Set<int> _selectedRows = {};

  AttendanceDataSource({required this.attendanceData})
      : filteredData = List.from(attendanceData);

  // Méthode pour trier les données
  void sort<T>(
      Comparable<T> Function(AttendanceData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final AttendanceData c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      if (getField(a) is int) {
        return ascending
            ? aValue.compareTo(bValue as T)
            : bValue.compareTo(aValue as T);
      } else {
        return Comparable.compare(aValue, bValue);
      }
    });
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  // Méthode pour filtrer les données par catégorie (statut)
  void filter(String? category) {
    if (category == null || category.isEmpty) {
      filteredData = List.from(attendanceData);
    } else {
      filteredData = attendanceData
          .where((data) => (data.statut ? "Présent" : "Absent") == category)
          .toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  void filterBySearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      filteredData = List.from(attendanceData);
    } else {
      filteredData = attendanceData
          .where((data) =>
              data.matricule.contains(searchQuery) ||
              data.nom.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final attendance = filteredData[index];
    int mat = int.parse(filteredData[index].matricule);
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
        DataCell(Text('$mat')),
        DataCell(Text(attendance.nom.toUpperCase())),
        DataCell(
          attendance.statut
              ? const Icon(Icons.check, color: Colors.green)
              : const Icon(Icons.close, color: Colors.red),
        ),
      ],
    );
  }

  // Méthode pour gérer la sélection d'une ligne
  void _handleRowSelected(bool? selected, int rowIndex) {
    if (selected!) {
      _selectedRows.add(rowIndex);
    } else {
      _selectedRows.remove(rowIndex);
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => filteredData.length;

  @override
  int get selectedRowCount => _selectedRows.length;

  // Méthode pour obtenir la couleur d'une ligne en fonction de sa sélection
  Color _getRowColor(int index) {
    return _selectedRows.contains(index) ? Colors.green : Colors.grey[200]!;
  }
}

// Widget représentant la table paginée des présences
class AttendancePaginatedTable extends StatefulWidget {
  final List<AttendanceData> attendanceData;
  final Future<void> Function()? callback;
  final Future<void> Function()? imprimPdf;

  const AttendancePaginatedTable({
    Key? key,
    required this.attendanceData,
    this.callback,
    this.imprimPdf,
  }) : super(key: key);

  @override
  _AttendancePaginatedTableState createState() =>
      _AttendancePaginatedTableState();
}

class _AttendancePaginatedTableState extends State<AttendancePaginatedTable> {
  late AttendanceDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  String? _selectedCategory;
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataSource = AttendanceDataSource(attendanceData: widget.attendanceData);
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(AttendanceData d) getField,
      int columnIndex, bool ascending) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    TextField searchField = TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.only(top: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 3.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blue, width: 3.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _dataSource.filterBySearch(value);
          });
        });
    return PaginatedDataTable(
      actions: [
        SizedBox(
          width: isSmallScreen ? 100 : 200,
          child: searchField,
        ),
        // Menu déroulant pour filtrer par statut
        SizedBox(
          width: isSmallScreen ? 150 : 250,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filtrer par statut',
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: AppColors.secondaryColor,
                  width: 3.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                    color: AppColors.secondaryColor, width: 3.0),
              ),
            ),
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
                _dataSource.filter(newValue);
              });
            },
            items: <String>['Présent', 'Absent']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        // Bouton pour rafraîchir les données
        IconButton(
          color: Colors.blue,
          splashColor: Colors.transparent,
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            await widget.callback!();
          },
        ),
        // Bouton pour imprimer en PDF
        IconButton(
          color: Colors.black,
          onPressed: () async {
            await widget.imprimPdf!();
          },
          icon: const Icon(Icons.print),
        ),
      ],
      header: const Text(
        'Liste de présence',
        textAlign: TextAlign.center,
      ),
      columns: [
        DataColumn(
          numeric: true,
          label: const Text(
            'Matricule',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onSort: (int columnIndex, bool ascending) => _sort<String>(
              (AttendanceData d) => d.matricule, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text(
            'Nom',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onSort: (int columnIndex, bool ascending) => _sort<String>(
              (AttendanceData d) => d.nom, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text(
            'Présence',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onSort: (int columnIndex, bool ascending) => _sort<String>(
              (AttendanceData d) => d.statut.toString(),
              columnIndex,
              ascending),
        ),
      ],
      source: _dataSource,
      rowsPerPage: 7,
      columnSpacing: 10,
      horizontalMargin: 10,
      showCheckboxColumn: true,
      showFirstLastButtons: true,
      showEmptyRows: false,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey),
    );
  }
}
