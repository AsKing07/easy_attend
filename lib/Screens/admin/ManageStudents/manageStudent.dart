// ignore_for_file: use_build_context_synchronously, file_names, prefer_typing_uninitialized_variables, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addNewStudent.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addStudent.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/edit_Student.dart';

import 'package:easy_attend/Widgets/helper.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageStudentPage extends StatefulWidget {
  const ManageStudentPage({super.key});
  @override
  State<ManageStudentPage> createState() => _ManageStudentPageState();
}

class _ManageStudentPageState extends State<ManageStudentPage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  List<StudentData> studentData = [];
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
      List<dynamic> students;
      List<dynamic> inactifStudents;
      response =
          await http.get(Uri.parse('$BACKEND_URL/api/student/getStudentData'));

      if (response.statusCode == 200) {
        students = jsonDecode(response.body);
        final newResponse = await http
            .get(Uri.parse(('$BACKEND_URL/api/student/getInactifStudentData')));
        if (newResponse.statusCode == 200) {
          inactifStudents = json.decode(newResponse.body);
          List<dynamic> allStudents = [...students, ...inactifStudents];
          studentData.clear();
          for (var entry in allStudents) {
            studentData.add(StudentData(student: entry));
          }
          setState(() {
            dataIsLoading = false;
          });
        } else {
          print(newResponse.body);
          Helper().ErrorMessage(context);
        }
      } else {
        print(response.body);

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
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: StudentPaginatedTable(
                        key: ValueKey(studentData),
                        studentData: studentData,
                        callback: fetchData,
                        callback2: fetchData,
                        allFilieres: Allfilieres,
                      ),
                    )
                  ],
                )
              ],
            ),
          ));
  }
}

// Classe représentant les données de etudiants
class StudentData {
  final dynamic student;

  StudentData({
    required this.student,
  });
}

// Classe représentant la source des données pour le DataTable
class StudentDataSource extends DataTableSource {
  BuildContext context;
  void Function() callback;
  List<StudentData> studentData;
  List<StudentData> filteredData;
  final Set<int> _selectedRows = {};

  StudentDataSource({
    required this.studentData,
    required this.context,
    required this.callback,
  }) : filteredData = List.from(studentData);

  // Méthode pour trier les données
  void sort<T>(Comparable<T> Function(StudentData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final StudentData c = a;
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
  void filterByStatut(bool? statut) {
    if (statut == null) {
      filteredData = List.from(studentData);
    } else {
      filteredData = studentData.where((data) {
        return (data.student['statut'] == 1) == statut;
      }).toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  // Méthode pour filtrer les données par filiere
  void filterByFiliere(String? filiere) {
    if (filiere == null || filiere.isEmpty) {
      filteredData = List.from(studentData);
    } else {
      filteredData = studentData
          .where((data) =>
              data.student['filiere'].toUpperCase() == filiere.toUpperCase())
          .toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  // Méthode pour filtrer les données par niveau
  void filterByNiveau(String? niveau) {
    if (niveau == null || niveau.isEmpty || niveau == 'Toutes les niveau') {
      filteredData = List.from(studentData);
    } else {
      filteredData = studentData
          .where((data) =>
              data.student['niveau'].toUpperCase() == niveau.toUpperCase())
          .toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  void filterBySearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      filteredData = List.from(studentData);
    } else {
      filteredData = studentData
          .where((data) =>
              data.student['nom']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.student['prenom']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.student['filiere']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.student['matricule']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.student['email']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.student['niveau']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    String imageUrl = filteredData[index].student['image'] ??
        "assets/admin.jpg"; // Default image

    final data = filteredData[index];
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
        DataCell(Text('${data.student['matricule']}'.toUpperCase())),
        DataCell(Text('${data.student['nom']}'.toUpperCase())),
        DataCell(Text('${data.student['prenom']}'.toUpperCase())),
        DataCell(Text('${data.student['email']}'.toLowerCase())),
        DataCell(Text('${data.student['phone']}'.toUpperCase())),
        DataCell(
          imageUrl.startsWith('http')
              ? GFAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(imageUrl))
              : GFAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage(imageUrl),
                ),
        ),
        DataCell(Text('${data.student['filiere']}'.toUpperCase())),
        DataCell(Text('${data.student['niveau']}'.toUpperCase())),
        data.student['statut'] == 1
            ? DataCell(Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      //Page de modification en passant l'ID
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: EditStudentPage(
                                          studentId: data.student['uid'],
                                          callback: callback),
                                    )),
                              ));
                    },
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.redColor),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 10),
                              Text(
                                "Supprimer l' étudiant",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer cet étudiant ? ',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await set_Data().deleteOneStudent(
                                  data.student['uid'],
                                  context,
                                );
                                callback();

                                Navigator.of(context).pop();
                              },
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ))
            : DataCell(
                IconButton(
                  icon: const Icon(
                    Icons.restore,
                    color: AppColors.greenColor,
                  ),
                  onPressed: () {
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
                              "Restaurer l'étudiant",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir restaurer cet étudiant ? '),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await set_Data().restoreOneStudent(
                                  data.student['uid'], context);
                              callback();

                              Navigator.of(context).pop();
                            },
                            child: const Text('Restaurer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
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

class StudentPaginatedTable extends StatefulWidget {
  final List<StudentData> studentData;
  final Future<void> Function() callback;
  final Future<void> Function() callback2;
  final List<Filiere> allFilieres;

  const StudentPaginatedTable({
    Key? key,
    required this.studentData,
    required this.callback,
    required this.callback2,
    required this.allFilieres,
  }) : super(key: key);

  @override
  _StudentPaginatedTableState createState() => _StudentPaginatedTableState();
}

class _StudentPaginatedTableState extends State<StudentPaginatedTable> {
  late StudentDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  bool _selectedFiltre = true;
  String? _selectedNiveau;
  Filiere? _selectedFiliere;
  late final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _dataSource = StudentDataSource(
      studentData: widget.studentData,
      context: context,
      callback: widget.callback,
    );
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(StudentData d) getField, int columnIndex,
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
            color: AppColors.secondaryColor,
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
          _selectedFiltre
              ? const Text(
                  textAlign: TextAlign.center,
                  "Gestion des étudiants",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge),
                )
              : const Text(
                  textAlign: TextAlign.center,
                  "Corbeille des étudiants",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge),
                ),
          const SizedBox(height: 15),
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
                  child: DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                    elevation: 18,
                    onChanged: (value) {
                      setState(() {
                        _selectedFiltre = value == 'Actif' ? true : false;

                        _dataSource.filterByStatut(_selectedFiltre);
                      });
                    },
                    items: ['Actif', 'Corbeille']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
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
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 3.0),
                      ),
                    ),
                  ),
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
                      labelText: 'Filtrer par filière',
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
                        labelText: 'Filtrer par niveau',
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
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child:
                                      AddStudent(callback: widget.callback2)),
                            ));
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
                              "Supprimer tous les étudiants",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer tous les étudiants?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await set_Data().deleteAllStudents(context);
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
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                    elevation: 18,
                    onChanged: (value) {
                      setState(() {
                        _selectedFiltre = value == 'Actif' ? true : false;

                        _dataSource.filterByStatut(_selectedFiltre);
                      });
                    },
                    items: ['Actif', 'Corbeille']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
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
                      labelText: 'Filtrer par statut',
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
                          showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                    child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: AddStudent(
                                            callback: widget.callback2)),
                                  ));
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
                                    "Supprimer tous les étudiants",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer tous les étudiants?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await set_Data().deleteAllStudents(context);
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
              actions: isSmallScreen ? null : [],
              header: const Text(
                'Liste des étudiants',
                textAlign: TextAlign.center,
              ),
              columns: [
                DataColumn(
                  numeric: true,
                  label: const Text(
                    'Matricule',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['matricule'],
                      columnIndex,
                      ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Nom',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['nom'],
                      columnIndex,
                      ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Prénom',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['prenom'],
                      columnIndex,
                      ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Email',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['email'],
                      columnIndex,
                      ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Phone',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['phone'],
                      columnIndex,
                      ascending),
                ),
                const DataColumn(
                  label: Text(
                    'Photo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'Filiere',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['filiere'],
                      columnIndex,
                      ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Niveau',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (StudentData d) => d.student['niveau'],
                      columnIndex,
                      ascending),
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
              rowsPerPage: 5,
              columnSpacing: 10,
              horizontalMargin: 10,
              showCheckboxColumn: true,
              showFirstLastButtons: true,
              showEmptyRows: false,
              dataRowMaxHeight: 100,
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
