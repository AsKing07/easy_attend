// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/addNewFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/editFiliere.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ManageFilierePage extends StatefulWidget {
  const ManageFilierePage({Key? key}) : super(key: key);

  @override
  _ManageFilierePageState createState() => _ManageFilierePageState();
}

class _ManageFilierePageState extends State<ManageFilierePage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  bool dataIsLoading = true;
  List<FiliereData> filiereData = [];

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
      List<dynamic> filieres;
      List<dynamic> inactifFilieres;
      //Récupération des filières actives
      final response =
          await http.get(Uri.parse('$BACKEND_URL/api/filiere/getFiliereData'));
      if (response.statusCode == 200) {
        filieres = json.decode(response.body);
        //Récupération des filières inactives

        final newResponse = await http
            .get(Uri.parse(('$BACKEND_URL/api/filiere/getInactifFiliereData')));
        if (newResponse.statusCode == 200) {
          inactifFilieres = jsonDecode(newResponse.body);
          //Concaténations des deux listes
          List<dynamic> allFilieres = [...filieres, ...inactifFilieres];
          filiereData.clear();
          for (var entry in allFilieres) {
            filiereData.add(FiliereData(filiere: entry));
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
                content:
                    Text('Impossible de récupérer les filières. Erreur:$e'),
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
                      child: FilierePaginatedTable(
                        key: ValueKey(filiereData),
                        filiereData: filiereData,
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

// Classe représentant les données de filiere
class FiliereData {
  final dynamic filiere;

  FiliereData({
    required this.filiere,
  });
}

// Classe représentant la source des données pour le DataTable
class FiliereDataSource extends DataTableSource {
  BuildContext context;
  void Function() callback;
  List<FiliereData> filiereData;
  List<FiliereData> filteredData;
  final Set<int> _selectedRows = {};

  FiliereDataSource({
    required this.filiereData,
    required this.context,
    required this.callback,
  }) : filteredData = List.from(filiereData);

  // Méthode pour trier les données
  void sort<T>(Comparable<T> Function(FiliereData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final FiliereData c = a;
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
      filteredData = List.from(filiereData);
    } else {
      filteredData = filiereData.where((data) {
        return (data.filiere['statut'] == 1) == statut;
      }).toList();
    }
    notifyListeners(); // Notifie les auditeurs des modifications
  }

  void filterBySearch(String searchQuery) {
    if (searchQuery.isEmpty) {
      filteredData = List.from(filiereData);
    } else {
      filteredData = filiereData
          .where((data) =>
              data.filiere['nomFiliere']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              data.filiere['sigleFiliere']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final data = filteredData[index];
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
          DataCell(Text(data.filiere['sigleFiliere'].toUpperCase())),
        DataCell(Text(data.filiere['nomFiliere'].toUpperCase())),
        if (!isSmallScreen)
          DataCell(Text(
            data.filiere['niveaux'].toUpperCase(),
            style: const TextStyle(fontSize: FontSize.small),
          )),
        data.filiere['statut'] == 1
            ? DataCell(Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      //Page de modification en passant l'ID
                      currentPage.updatePage(MenuItems(
                          text: "Modifier filière",
                          tap: ModifierFilierePage(
                              filiereId: data.filiere['idFiliere'],
                              callback: callback)));
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
                                "Supprimer la filière",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer cette filière ? \n Cela entraînera la suppression automatique des \n cours et étudiants associés à cette filière.',
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
                                await set_Data().deleteFiliere(
                                  data.filiere['idFiliere'],
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
                              "Restaurer la filière",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir restaurer cette filière ?  Les étudiants et cours seront également restaurés! '),
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
                              await set_Data().restoreFiliere(
                                  data.filiere['idFiliere'], context);
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

class FilierePaginatedTable extends StatefulWidget {
  final List<FiliereData> filiereData;
  final Future<void> Function() callback;
  final Future<void> Function() callback2;

  const FilierePaginatedTable({
    Key? key,
    required this.filiereData,
    required this.callback,
    required this.callback2,
  }) : super(key: key);

  @override
  _FilierePaginatedTableState createState() => _FilierePaginatedTableState();
}

class _FilierePaginatedTableState extends State<FilierePaginatedTable> {
  late FiliereDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  bool _selectedFiltre = true;
  String? _selectedNiveau;
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dataSource = FiliereDataSource(
      filiereData: widget.filiereData,
      context: context,
      callback: widget.callback,
    );
    // _dataSource.filterByStatut(_selectedFiltre);
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(FiliereData d) getField, int columnIndex,
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
          _selectedFiltre
              ? const Text(
                  textAlign: TextAlign.center,
                  "Gestion des filières",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                      fontSize: FontSize.xxxLarge),
                )
              : const Text(
                  textAlign: TextAlign.center,
                  "Corbeille des filières",
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
                        text: "Ajouter une filière",
                        tap: addNewFilierePage(callback: widget.callback2)));
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
                              "Supprimer toutes les filières",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        content: const Text(
                            'Êtes-vous sûr de vouloir supprimer toutes les filieres?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await set_Data().deleteAllFiliere(context);
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
                          currentPage.updatePage(MenuItems(
                              text: "Ajouter une filière",
                              tap: addNewFilierePage(
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
                                    "Supprimer toutes les filières",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer toutes les filières?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await set_Data().deleteAllFiliere(context);
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
                'Liste des filières',
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
                        (FiliereData d) => d.filiere['sigleFiliere'],
                        columnIndex,
                        ascending),
                  ),
                DataColumn(
                  label: const Text(
                    'Filières',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onSort: (int columnIndex, bool ascending) => _sort<String>(
                      (FiliereData d) => d.filiere['nomFiliere'],
                      columnIndex,
                      ascending),
                ),
                if (!isSmallScreen)
                  const DataColumn(
                    label: Text(
                      'Niveaux',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    // onSort: (int columnIndex, bool ascending) => _sort<String>(
                    //     (FiliereData d) => d.filiere['niveaux'], columnIndex, ascending),
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
