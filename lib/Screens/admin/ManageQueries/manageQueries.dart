// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ManageQueriesPage extends StatefulWidget {
  const ManageQueriesPage({Key? key}) : super(key: key);

  @override
  State<ManageQueriesPage> createState() => _ManageQueriesPageState();
}

class _ManageQueriesPageState extends State<ManageQueriesPage> {
  List<Map<String, String>> statutDisponibles = [
    {"nom": "Approuvé", "valeur": "1"},
    {"nom": "Refusé", "valeur": "0"},
    {"nom": "En attente", "valeur": "2"}
  ];
  Map<String, dynamic> filter = {
    'nom': '',
    'valeur': '',
  };

  String selectedFilter = '';
  final BACKEND_URL = dotenv.env['API_URL'];
  List<QueryData> queryData = [];

  bool dataIsLoading = true;

  Future<void> fetchData() async {
    setState(() {
      dataIsLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('$BACKEND_URL/api/requete/getRequestData'));
      if (response.statusCode == 200) {
        List<dynamic> requetes = jsonDecode(response.body);
        queryData.clear();
        for (var entry in requetes) {
          queryData.add(QueryData(query: entry));
        }
        setState(() {
          dataIsLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer les requêtes. '),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      !kReleaseMode
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Impossible de récupérer les requêtes. Erreur:$e'),
                duration: const Duration(seconds: 6),
                backgroundColor: Colors.red,
              ),
            )
          : Helper().ErrorMessage(context,
              content: "Impossible de récupérer les requêtes.");
    }
  }

  String getAuteur(String input) {
    List<String> words = input.split(' ');
    return '${words[0]} ${words[1]}';
  }

  String getDetailsExceptAuteur(String input) {
    List<String> words = input.split(' ');
    List<String> remainingWords = words.sublist(3);
    return remainingWords.join(' ');
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
            body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: QueryPaginatedTable(
                        key: ValueKey(queryData),
                        queryData: queryData,
                        callback: fetchData,
                        callback2: fetchData,
                      ),
                    )
                  ],
                )
              ],
            ),
          ));

    // Scaffold(
    //   body: SingleChildScrollView(
    //     child: Padding(
    //       padding: const EdgeInsets.all(20.0),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(
    //             "Gestion des requêtes",
    //             style: GoogleFonts.poppins(
    //                 color: AppColors.textColor,
    //                 fontSize: FontSize.xxLarge,
    //                 fontWeight: FontWeight.w600),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(top: 7),
    //             child: Text(
    //               "Analysez ici vos requêtes",
    //               style: GoogleFonts.poppins(
    //                   color: AppColors.primaryColor,
    //                   fontSize: FontSize.medium,
    //                   fontWeight: FontWeight.w600),
    //             ),
    //           ),
    //           const SizedBox(height: 30),
    //           Wrap(
    //             alignment: WrapAlignment.center,
    //             spacing: !screenSize().isWeb() ? 8 : 32,
    //             children: statutDisponibles.map((item) {
    //               return FilterChip(
    //                 label: Text(item['nom'] as String),
    //                 selected: selectedFilter == item['valeur'],
    //                 onSelected: (bool selected) {
    //                   setState(() {
    //                     selectedFilter =
    //                         selected ? item['valeur'] as String : '';
    //                     filter['nom'] = item['nom'] as String;
    //                     filter['valeur'] = selectedFilter;
    //                     fetchData();
    //                   });
    //                 },
    //               );
    //             }).toList(),
    //           ),
    //           const SizedBox(height: 16),
    //           SizedBox(
    //             height: MediaQuery.of(context).size.height - 180,
    //             child: StreamBuilder<List<dynamic>>(
    //               stream: _streamController.stream,
    //               builder: (context, snapshot) {
    //                 if (snapshot.connectionState == ConnectionState.waiting) {
    //                   return Center(
    //                     child: LoadingAnimationWidget.hexagonDots(
    //                         color: AppColors.secondaryColor, size: 100),
    //                   );
    //                 } else if (snapshot.hasError) {
    //                   return errorWidget(error: snapshot.error.toString());
    //                 } else {
    //                   List<dynamic>? requetes = snapshot.data;
    //                   if (requetes!.isEmpty) {
    //                     return const SingleChildScrollView(
    //                       child: NoResultWidget(),
    //                     );
    //                   } else {
    //                     return ListView.builder(
    //                       itemCount: requetes.length,
    //                       itemBuilder: (context, index) {
    //                         final query = requetes[index];
    //                         return Card(
    //                           elevation: 4,
    //                           margin: const EdgeInsets.symmetric(vertical: 10),
    //                           shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(15),
    //                           ),
    //                           child: Column(
    //                             children: [
    //                               ListTile(
    //                                 title: Text(
    //                                   query['type'].toString(),
    //                                   style: const TextStyle(
    //                                       color: AppColors.secondaryColor,
    //                                       fontSize: FontSize.medium,
    //                                       fontWeight: FontWeight.w400),
    //                                 ),
    //                                 trailing: query['statut'] == "1"
    //                                     ? const Icon(Icons.check,
    //                                         color: AppColors.greenColor)
    //                                     : query['statut'] == "2"
    //                                         ? const Icon(Icons.sync,
    //                                             color: AppColors.studColor)
    //                                         : const Icon(Icons.cancel,
    //                                             color: AppColors.redColor),
    //                                 onTap: () {
    //                                   setState(() {
    //                                     query['isExpanded'] =
    //                                         !query['isExpanded'];
    //                                   });
    //                                 },
    //                               ),
    //                               if (query['isExpanded'])
    //                                 Padding(
    //                                   padding: const EdgeInsets.all(16.0),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.start,
    //                                     children: [
    //                                       Text(
    //                                         "Auteur : ${getAuteur(query['details'])}",
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: AppColors.textColor,
    //                                             fontWeight: FontWeight.w400),
    //                                       ),
    //                                       const SizedBox(height: 10),
    //                                       Text(
    //                                         "Détails: \n  ${getDetailsExceptAuteur(query['details'])}",
    //                                         style: const TextStyle(
    //                                             fontSize: 14,
    //                                             color: AppColors.textColor,
    //                                             fontWeight: FontWeight.w400),
    //                                       ),
    //                                       const SizedBox(height: 10),
    //                                       Row(
    //                                         children: [
    //                                           Flexible(
    //                                             child: GFButton(
    //                                               color: AppColors.white,
    //                                               onPressed: () async {
    //                                                 await set_Data()
    //                                                     .approuverRequete(
    //                                                         query['idRequete'],
    //                                                         context);
    //                                                 setState(() {
    //                                                   selectedFilter = "1";
    //                                                   filter['valeur'] = "1";
    //                                                   fetchData();
    //                                                 });
    //                                               },
    //                                               shape: GFButtonShape.pills,
    //                                               child: const Icon(
    //                                                 Icons.check,
    //                                                 color: AppColors.greenColor,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           const SizedBox(width: 10),
    //                                           Flexible(
    //                                             child: GFButton(
    //                                               color: AppColors.white,
    //                                               onPressed: () async {
    //                                                 await set_Data()
    //                                                     .desapprouverRequete(
    //                                                         query['idRequete'],
    //                                                         context);
    //                                                 setState(() {
    //                                                   selectedFilter = "0";
    //                                                   filter['valeur'] = "0";
    //                                                   fetchData();
    //                                                 });
    //                                               },
    //                                               shape: GFButtonShape.pills,
    //                                               child: const Icon(
    //                                                 Icons.cancel,
    //                                                 color: AppColors.redColor,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           const SizedBox(width: 10),
    //                                           Flexible(
    //                                             child: GFButton(
    //                                               color: AppColors.white,
    //                                               onPressed: () async {
    //                                                 await set_Data()
    //                                                     .mettreEnAttenteRequete(
    //                                                         query['idRequete'],
    //                                                         context);
    //                                                 setState(() {
    //                                                   selectedFilter = "2";
    //                                                   filter['valeur'] = "2";
    //                                                   fetchData();
    //                                                 });
    //                                               },
    //                                               shape: GFButtonShape.pills,
    //                                               child: const Icon(
    //                                                 Icons.sync,
    //                                                 color: AppColors.studColor,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                             ],
    //                           ),
    //                         );
    //                       },
    //                     );
    //                   }
    //                 }
    //               },
    //             ),
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class QueryData {
  final dynamic query;
  QueryData({required this.query});
}

class QueryDataSource extends DataTableSource {
  BuildContext context;
  void Function() callback;
  List<QueryData> queryData;
  List<QueryData> filteredData;
  final Set<int> _selectedRows = {};

  QueryDataSource({
    required this.queryData,
    required this.context,
    required this.callback,
  }) : filteredData = queryData.where((data) {
          return (data.query['statut'] == '2');
        }).toList();

  // Méthode pour trier les données
  void sort<T>(Comparable<T> Function(QueryData d) getField, bool ascending) {
    filteredData.sort((a, b) {
      if (!ascending) {
        final QueryData c = a;
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

  // Méthode pour filtrer les données par statut
  void filterByStatut(String? statut) {
    if (statut == null) {
      filteredData = List.from(queryData);
    } else if (statut == '1') {
      filteredData = queryData.where((data) {
        return (data.query['statut'] == '1');
      }).toList();
    } else if (statut == '2') {
      filteredData = queryData.where((data) {
        return (data.query['statut'] == '2');
      }).toList();
    } else if (statut == '0') {
      filteredData = queryData.where((data) {
        return (data.query['statut'] == '0');
      }).toList();
    }

    notifyListeners(); // Notifie les auditeurs des modifications
  }

  @override
  DataRow getRow(int index) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    var currentPage = Provider.of<PageModelAdmin>(context);
    final data = filteredData[index];

    String getAuteur(String input) {
      List<String> words = input.split(' ');
      return '${words[0]} ${words[1]}';
    }

    String getDetailsExceptAuteur(String input) {
      List<String> words = input.split(' ');
      List<String> remainingWords = words.sublist(3);
      return remainingWords.join(' ');
    }

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
          DataCell(ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? 50 : 90), //SET max width
              child: Text('${data.query['type']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize:
                          isSmallScreen ? FontSize.xSmall : FontSize.medium)))),
          DataCell(ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? 45 : 90), //SET max width
              child: Text(getAuteur(data.query['details']).toUpperCase(),
                  style: TextStyle(
                      fontSize:
                          isSmallScreen ? FontSize.xSmall : FontSize.medium)))),
          DataCell(Text(getDetailsExceptAuteur(data.query['details']),
              style: TextStyle(
                  fontSize:
                      isSmallScreen ? FontSize.xSmall : FontSize.medium))),
          data.query['statut'] == '2'
              ? DataCell(PopupMenuButton(
                  color: AppColors.secondaryColor,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            child: InkWell(
                                onTap: () async {
                                  await set_Data().approuverRequete(
                                      data.query['idRequete'], context);
                                  callback();
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: AppColors.greenColor,
                                    ),
                                    Text("Approuver",
                                        style:
                                            TextStyle(color: AppColors.white))
                                  ],
                                ))),
                        PopupMenuItem(
                            child: InkWell(
                                onTap: () async {
                                  await set_Data().desapprouverRequete(
                                      data.query['idRequete'], context);
                                  callback();
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.cancel,
                                      color: AppColors.redColor,
                                    ),
                                    Text("Rejeter",
                                        style:
                                            TextStyle(color: AppColors.white))
                                  ],
                                ))),
                      ]))
              : DataCell(PopupMenuButton(
                  color: AppColors.secondaryColor,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            child: InkWell(
                                onTap: () async {
                                  await set_Data().mettreEnAttenteRequete(
                                      data.query['idRequete'], context);
                                  callback();
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      color: AppColors.studColor,
                                    ),
                                    Text("Mettre en Attente",
                                        style:
                                            TextStyle(color: AppColors.white))
                                  ],
                                ))),
                      ]))
        ]);
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

// Widget représentant la table paginée des étudiants

class QueryPaginatedTable extends StatefulWidget {
  final List<QueryData> queryData;
  final Future<void> Function() callback;
  final Future<void> Function() callback2;

  const QueryPaginatedTable({
    Key? key,
    required this.queryData,
    required this.callback,
    required this.callback2,
  }) : super(key: key);

  @override
  _QueryPaginatedTableState createState() => _QueryPaginatedTableState();
}

class _QueryPaginatedTableState extends State<QueryPaginatedTable> {
  late QueryDataSource _dataSource;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  String selectedFilter = '2';

  @override
  void initState() {
    super.initState();
    _dataSource = QueryDataSource(
      queryData: widget.queryData,
      context: context,
      callback: widget.callback,
    );
  }

  // Méthode pour trier les colonnes
  void _sort<T>(Comparable<T> Function(QueryData d) getField, int columnIndex,
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
    List<Map<String, String>> statutDisponibles = [
      {"nom": "Approuvé", "valeur": "1"},
      {"nom": "Refusé", "valeur": "0"},
      {"nom": "En attente", "valeur": "2"}
    ];

    Wrap statutWrap = Wrap(
      alignment: WrapAlignment.center,
      spacing: !screenSize().isWeb() ? 8 : 32,
      children: statutDisponibles.map((item) {
        return FilterChip(
          label: Text(item['nom'] as String),
          selected: selectedFilter == item['valeur'],
          onSelected: (bool selected) {
            setState(() {
              selectedFilter = selected ? item['valeur']! : '';

              _dataSource.filterByStatut(selectedFilter);
            });
          },
        );
      }).toList(),
    );
    String getAuteur(String input) {
      List<String> words = input.split(' ');
      return '${words[0]} ${words[1]}';
    }

    String getDetailsExceptAuteur(String input) {
      List<String> words = input.split(' ');
      List<String> remainingWords = words.sublist(3);
      return remainingWords.join(' ');
    }

    return Column(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                statutWrap,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PaginatedDataTable(
                    header: const Text(
                      'Gestion des Requêtes',
                      textAlign: TextAlign.center,
                    ),
                    columns: [
                      DataColumn(
                        label: const Text(
                          'Type',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onSort: (int columnIndex, bool ascending) =>
                            _sort<String>((QueryData d) => d.query['type'],
                                columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text(
                          'Auteur',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onSort: (int columnIndex, bool ascending) =>
                            _sort<String>(
                                (QueryData d) => getAuteur(d.query['details']),
                                columnIndex,
                                ascending),
                      ),
                      DataColumn(
                        label: const Text(
                          'Détails',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onSort: (int columnIndex, bool ascending) =>
                            _sort<String>(
                                (QueryData d) =>
                                    getDetailsExceptAuteur(d.query['details']),
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
                    rowsPerPage: isSmallScreen ? 8 : 10,
                    columnSpacing: 10,
                    horizontalMargin: 10,
                    showCheckboxColumn: true,
                    showFirstLastButtons: true,
                    showEmptyRows: false,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    headingRowColor:
                        MaterialStateColor.resolveWith((states) => Colors.grey),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
