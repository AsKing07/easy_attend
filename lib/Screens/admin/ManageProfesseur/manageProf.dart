// ignore_for_file: use_build_context_synchronously, file_names, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/addNewProf.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/edit_Prof.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageProf extends StatefulWidget {
  const ManageProf({super.key});

  @override
  State<ManageProf> createState() => _ManageProfState();
}

class _ManageProfState extends State<ManageProf> {
  final BACKEND_URL = dotenv.env['API_URL'];
  bool dataIsLoading = true;
  List<ProfData> profData = [];

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      dataIsLoading = true;
    });
    try {
      List<dynamic> profs;
      List<dynamic> inactifProfs;
      final response =
          await http.get(Uri.parse('$BACKEND_URL/api/prof/getProfData'));

      if (response.statusCode == 200) {
        profs = jsonDecode(response.body);
        final newResponse = await http
            .get(Uri.parse(('$BACKEND_URL/api/prof/getInactifProfData')));
        if (newResponse.statusCode == 200) {
          inactifProfs = jsonDecode(newResponse.body);
          List<dynamic> allProfs = [...profs, ...inactifProfs];
          profData.clear();
          for (var entry in allProfs) {
            profData.add(ProfData(prof: entry));
          }
          setState(() {
            dataIsLoading = false;
          });
        } else {
          Helper().ErrorMessage(context);
        }
      } else {
        Helper().ErrorMessage(context);
      }
    } catch (e) {
      // Gérer les erreurs ici
      kReleaseMode
          ? Helper().ErrorMessage(context)
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Impossible de récupérer les profs. Erreur:$e'),
                duration: const Duration(seconds: 100),
                backgroundColor: Colors.red,
              ),
            );
    }
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
                      child: ProfPaginatedTable(
                        key: ValueKey(profData),
                        profData: profData,
                        callback: fetchData,
                        callback2: fetchData,
                      ),
                    )
                  ],
                )
              ],
            ),
          ));
  }
}

// Classe représentant les données de professeur
class ProfData {
  final dynamic prof;

  ProfData({
    required this.prof,
  });
}

// Classe représentant la source des données pour le DataTable
class ProfDataSource extends DataTableSource {
  BuildContext context;
  void Function() callback;
  List<ProfData> profData;
  List<ProfData> filteredData;
  final Set<int> _selectedRows = {};

  ProfDataSource({
    required this.profData,
    required this.context,
    required this.callback,
  }) : filteredData = List.from(profData);

  // Méthode pour trier les données
  void sort<T>(Comparable<T> Function(ProfData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final ProfData c = a;
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
      filteredData = List.from(profData);
    } else {
      filteredData = profData.where((data) {
        return (data.prof['statut'] == 1) == statut;
      }).toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  void filterBySearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      filteredData = List.from(profData);
    } else {
      filteredData = profData
          .where((data) =>
              data.prof['nom']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.prof['prenom']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    String imageUrl = filteredData[index].prof['image'] ??
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
        DataCell(Text('${data.prof['nom']}'.toUpperCase())),
        DataCell(Text('${data.prof['prenom']}'.toUpperCase())),
        DataCell(Text('${data.prof['email']}'.toLowerCase())),
        DataCell(Text('${data.prof['phone']}'.toUpperCase())),
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
        data.prof['statut'] == 1
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
                                      child: EditProfPage(
                                          profId: data.prof['uid'],
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
                                "Supprimer le professeur",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer ce professeur ? ',
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
                                await set_Data().deleteProf(
                                  data.prof['uid'],
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
                              "Restaurer le professeur",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir restaurer ce professeur ? '),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Restaurer la filière de Firestore
                              await set_Data()
                                  .restoreProf(data.prof['uid'], context);
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

class ProfPaginatedTable extends StatefulWidget {
  final List<ProfData> profData;
  final Future<void> Function() callback;
  final Future<void> Function() callback2;

  const ProfPaginatedTable({
    Key? key,
    required this.profData,
    required this.callback,
    required this.callback2,
  }) : super(key: key);

  @override
  _ProfPaginatedTableState createState() => _ProfPaginatedTableState();
}

class _ProfPaginatedTableState extends State<ProfPaginatedTable> {
  late ProfDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  bool _selectedFiltre = true;
  String? _selectedNiveau;
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataSource = ProfDataSource(
      profData: widget.profData,
      context: context,
      callback: widget.callback,
    );
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(ProfData d) getField, int columnIndex,
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
                  "Gestion des professeurs",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge),
                )
              : const Text(
                  textAlign: TextAlign.center,
                  "Corbeille des professeurs",
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
                                  child: addNewProfPage(
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
                              "Supprimer tous les professeurs",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer tous les professeurs?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await set_Data().deleteAllProf(context);
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: addNewProfPage(
                                                callback: widget.callback2))),
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
                                    "Supprimer tous les professeurs",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer tous les professeurs?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await set_Data().deleteAllProf(context);
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
                'Liste des professeurs',
                textAlign: TextAlign.center,
              ),
              columns: [
                DataColumn(
                  label: const Text(
                    'Nom',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (ProfData d) => d.prof['nom'], columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Prénom',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (ProfData d) => d.prof['prenom'], columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Email',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (ProfData d) => d.prof['email'], columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text(
                    'Phone',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (ProfData d) => d.prof['phone'], columnIndex, ascending),
                ),
                const DataColumn(
                  label: Text(
                    'Photo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
