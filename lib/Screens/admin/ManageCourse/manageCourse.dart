// ignore_for_file: use_build_context_synchronously, file_names, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/addNewCourse.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/editCourse.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../Models/menuItems.dart';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  List<CourseData> courseData = [];
  bool dataIsLoading = true;
  List<Filiere> Allfilieres = [];

  Future<void> loadAllActifFilieres() async {
    List<dynamic> docsFiliere = await get_Data().getActifFiliereData(context);
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      Filiere filiere = Filiere(
        idDoc: doc['idFiliere'].toString(),
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["sigleFiliere"],
        statut: doc["statut"] == 1,
        niveaux: doc['niveaux'].split(','),
      );

      fil.add(filiere);
    }

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  Future<void> fetchData() async {
    setState(() {
      dataIsLoading = true;
    });
    http.Response response;
    try {
      response =
          await http.get(Uri.parse('$BACKEND_URL/api/cours/getCoursesData'));
      // }
      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        courseData.clear();
        for (var entry in courses) {
          final filiere =
              await get_Data().getFiliereById(entry['idFiliere'], context);
          final prof =
              await get_Data().getProfById(entry['idProfesseur'], context);

          final nomCours = entry['nomCours'];
          final sigle = entry['sigleCours'];
          final niveau = entry['niveau'];
          courseData.add(CourseData(
              idCours: entry['idCours'],
              nomCours: nomCours,
              sigle: sigle,
              niveau: niveau,
              nomProf: '${prof['nom']} ${prof['prenom']}',
              nomFiliere: filiere['nomFiliere']));
        }

        setState(() {
          dataIsLoading = false;
        });
      } else {
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      // Gérer les erreurs ici
      kReleaseMode
          ? Helper().ErrorMessage(context)
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Impossible de récupérer les étudiants. Erreur:$e'),
                duration: const Duration(seconds: 100),
                backgroundColor: Colors.red,
              ),
            );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    loadAllActifFilieres();
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
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Gestion des cours',
                    style: TextStyle(
                      fontSize: FontSize.xxxLarge,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CoursePaginatedTable(
                          key: ValueKey(courseData),
                          courseData: courseData,
                          callback: fetchData,
                          callback2: fetchData,
                          allFilieres: Allfilieres,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
  }
}

// Classe représentant les données de cours
class CourseData {
  final dynamic idCours;
  final String nomCours;
  final String sigle;
  final String niveau;
  final String nomProf;
  final String nomFiliere;

  CourseData({
    required this.idCours,
    required this.nomCours,
    required this.sigle,
    required this.niveau,
    required this.nomProf,
    required this.nomFiliere,
  });
}

// Classe représentant la source des données pour le DataTable
class CourseDataSource extends DataTableSource {
  BuildContext context;
  void Function() callback;
  List<CourseData> courseData;
  List<CourseData> filteredData;
  final Set<int> _selectedRows = {};

  CourseDataSource({
    required this.courseData,
    required this.context,
    required this.callback,
  }) : filteredData = List.from(courseData);

  // Méthode pour trier les données
  void sort<T>(Comparable<T> Function(CourseData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final CourseData c = a;
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

  // Méthode pour filtrer les données par filiere
  void filterByFiliere(String? filiere) {
    if (filiere == null ||
        filiere.isEmpty ||
        filiere == 'Toutes les filières') {
      filteredData = List.from(courseData);
    } else {
      filteredData = courseData
          .where(
              (data) => data.nomFiliere.toUpperCase() == filiere.toUpperCase())
          .toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  // Méthode pour filtrer les données par niveau
  void filterByNiveau(String? niveau) {
    if (niveau == null || niveau.isEmpty || niveau == 'Toutes les niveau') {
      filteredData = List.from(courseData);
    } else {
      filteredData = courseData
          .where((data) => data.niveau.toUpperCase() == niveau.toUpperCase())
          .toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  void filterBySearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      filteredData = List.from(courseData);
    } else {
      filteredData = courseData
          .where((data) =>
              data.nomCours.toLowerCase().contains(searchQuery.toLowerCase()) ||
              data.sigle.toLowerCase().contains(searchQuery.toLowerCase()) ||
              data.nomFiliere
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.niveau.toLowerCase().contains(searchQuery.toLowerCase()) ||
              data.nomProf.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final cours = filteredData[index];
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    var currentPage = Provider.of<PageModelAdmin>(context);
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
        if (!isSmallScreen)
          DataCell(Text(cours.sigle.toUpperCase(),
              style: TextStyle(
                  fontSize:
                      isSmallScreen ? FontSize.xSmall : FontSize.medium))),
        DataCell(Text(cours.nomCours.toUpperCase(),
            style: TextStyle(
                fontSize: isSmallScreen ? FontSize.xSmall : FontSize.medium))),
        if (!isSmallScreen)
          DataCell(Text(cours.nomFiliere.toUpperCase(),
              style: TextStyle(
                  fontSize:
                      isSmallScreen ? FontSize.xSmall : FontSize.medium))),
        if (!isSmallScreen)
          DataCell(Text(cours.niveau.toUpperCase(),
              style: TextStyle(
                  fontSize:
                      isSmallScreen ? FontSize.xSmall : FontSize.medium))),
        DataCell(Text(cours.nomProf.toUpperCase(),
            style: TextStyle(
                fontSize: isSmallScreen ? FontSize.xSmall : FontSize.medium))),
        DataCell(PopupMenuButton(
            color: AppColors.secondaryColor,
            itemBuilder: (context) => [
                  PopupMenuItem(
                      child: InkWell(
                          onTap: () {
                            //Page de modification en passant l'ID
                            currentPage.updatePage(MenuItems(
                              text: "Modifier Cours",
                              tap: EditCoursePage(
                                  id: cours.idCours, callback: callback),
                            ));
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              Text("Editer",
                                  style: TextStyle(color: AppColors.white))
                            ],
                          ))),
                  PopupMenuItem(
                      child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Supprimer le cours",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color: Colors.orange),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer ce cours ? \n Cette action est irréversible'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await set_Data()
                                          .deleteCours(cours.idCours, context);
                                      callback();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.redColor),
                              Text("Supprimer",
                                  style: TextStyle(color: AppColors.white))
                            ],
                          ))),
                ]))
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

// Widget représentant la table paginée des cours

class CoursePaginatedTable extends StatefulWidget {
  final List<CourseData> courseData;
  final Future<void> Function() callback;
  final Future<void> Function() callback2;
  final List<Filiere> allFilieres;

  const CoursePaginatedTable({
    Key? key,
    required this.courseData,
    required this.callback,
    required this.callback2,
    required this.allFilieres,
  }) : super(key: key);

  @override
  _CoursePaginatedTableState createState() => _CoursePaginatedTableState();
}

class _CoursePaginatedTableState extends State<CoursePaginatedTable> {
  late CourseDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  Filiere? _selectedFiliere;
  String? _selectedNiveau;
  late final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final List<int> _availableRowsPerPage = [5, 10, 20, 50];
  @override
  void initState() {
    super.initState();
    _dataSource = CourseDataSource(
      courseData: widget.courseData,
      context: context,
      callback: widget.callback,
    );
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(CourseData d) getField, int columnIndex,
      bool ascending) {
    _dataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    var currentPage = Provider.of<PageModelAdmin>(context);

    TextFormField searchField = TextFormField(
      controller: _searchController,
      keyboardType: TextInputType.text,
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
      },
    );

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          if (!isSmallScreen)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: searchField,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Filiere>(
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                    value: _selectedFiliere,
                    elevation: 18,
                    onChanged: (Filiere? value) {
                      setState(() {
                        _selectedFiliere = value;
                        _dataSource.filterByFiliere(value!.nomFiliere);
                      });
                    },
                    items: widget.allFilieres
                        .map<DropdownMenuItem<Filiere>>((Filiere value) {
                      return DropdownMenuItem<Filiere>(
                        value: value,
                        child: Text(
                          value.nomFiliere,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Filière',
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
                  ),
                ),
                const SizedBox(width: 10),
                if (_selectedFiliere != null)
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedNiveau = value!;
                          _dataSource.filterByNiveau(value);
                        });
                      },
                      items: _selectedFiliere!.niveaux
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Niveau',
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
                    ),
                  ),
                const SizedBox(width: 10),
                IconButton(
                  color: Colors.blue,
                  splashColor: Colors.transparent,
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    await widget.callback2();
                  },
                ),
                IconButton(
                  color: Colors.green,
                  splashColor: Colors.transparent,
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    currentPage.updatePage(MenuItems(
                        text: "Ajouter un cours",
                        tap: AddNewCoursePage(callback: widget.callback2)));
                  },
                ),
                IconButton(
                  color: Colors.red,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Supprimer tous les cours",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer tous les cours? \n Cette action est irréversible.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await set_Data().deleteAllCours(context);
                              Navigator.of(context).pop();
                              await widget.callback2();
                            },
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Filiere>(
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                    value: _selectedFiliere,
                    elevation: 18,
                    onChanged: (Filiere? value) {
                      setState(() {
                        _selectedFiliere = value;
                        _dataSource.filterByFiliere(value!.nomFiliere);
                      });
                    },
                    items: widget.allFilieres
                        .map<DropdownMenuItem<Filiere>>((Filiere value) {
                      return DropdownMenuItem<Filiere>(
                        value: value,
                        child: Text(
                          value.nomFiliere,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Filtrer par filière',
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 3.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 3.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedFiliere != null)
                    DropdownButtonFormField<String>(
                      value: _selectedNiveau,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedNiveau = value!;
                          _dataSource.filterByNiveau(value);
                        });
                      },
                      items: _selectedFiliere!.niveaux
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Filtrer par niveau',
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 3.0),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.blue,
                        splashColor: Colors.transparent,
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          await widget.callback2();
                        },
                      ),
                      IconButton(
                        color: Colors.green,
                        splashColor: Colors.transparent,
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          currentPage.updatePage(MenuItems(
                              text: "Ajouter un cours",
                              tap: AddNewCoursePage(
                                  callback: widget.callback2)));
                        },
                      ),
                      IconButton(
                        color: Colors.red,
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Supprimer tous les cours",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer tous les cours? Cette action est irréversible.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await set_Data().deleteAllCours(context);
                                    Navigator.of(context).pop();
                                    await widget.callback2();
                                  },
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  )
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PaginatedDataTable(
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Ligne par page:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _rowsPerPage,
                      items: _availableRowsPerPage
                          .map((int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              ))
                          .toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _rowsPerPage = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
              header: const Text(
                'Liste des cours',
                textAlign: TextAlign.center,
              ),
              columns: [
                if (!isSmallScreen)
                  DataColumn(
                    label: const Text(
                      'Sigle',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (CourseData d) => d.sigle, columnIndex, ascending),
                  ),
                DataColumn(
                  label: const Text(
                    'Cours',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (CourseData d) => d.nomCours, columnIndex, ascending),
                ),
                if (!isSmallScreen)
                  DataColumn(
                    label: const Text(
                      'Filiere',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (CourseData d) => d.nomFiliere, columnIndex, ascending),
                  ),
                if (!isSmallScreen)
                  DataColumn(
                    label: const Text(
                      'Niveau',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onSort: (int columnIndex, bool ascending) => _sort<String>(
                        (CourseData d) => d.niveau, columnIndex, ascending),
                  ),
                DataColumn(
                  label: const Text(
                    'Professeur',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (CourseData d) => d.nomProf, columnIndex, ascending),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              source: _dataSource,
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage: _availableRowsPerPage,
              onRowsPerPageChanged: (int? value) {
                setState(() {
                  _rowsPerPage = value ?? _defaultRowsPerPage;
                });
              },
              columnSpacing: 10,
              horizontalMargin: 10,
              showCheckboxColumn: true,
              showFirstLastButtons: true,

              // dataRowMaxHeight: 100,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.grey),
            ),
          )
        ],
      ),
    ));
  }
}
