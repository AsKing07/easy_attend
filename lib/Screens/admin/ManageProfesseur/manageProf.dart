// ignore_for_file: use_build_context_synchronously, file_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/addNewProf.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/prof_trashed.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/edit_Prof.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageProf extends StatefulWidget {
  const ManageProf({super.key});

  @override
  State<ManageProf> createState() => _ManageProfState();
}

class _ManageProfState extends State<ManageProf> {
  final TextEditingController _searchController = TextEditingController();
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  String searchFilter = 'Nom';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _onSearchChanged() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          '$BACKEND_URL/api/prof/getProfData?search=${_searchController.text}&filtre=$searchFilter'));

      if (response.statusCode == 200) {
        List<dynamic> profs = jsonDecode(response.body);
        _streamController.add(profs);
      } else {
        throw Exception('Erreur lors de la récupération des profs');
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les professeurs. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.secondaryColor,
            width: double.infinity,
            height: 80,
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: MediaQuery.of(context).size.width >= 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : MediaQuery.of(context).size.width >= 600
                      ? MediaQuery.of(context).size.width * 0.05
                      : 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.white,
                      ),
                      iconColor: AppColors.white,
                      hintText: "Rechercher",
                      hintStyle: TextStyle(color: AppColors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.white, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.white),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.white),
                    onChanged: (value) {
                      _onSearchChanged();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.white, width: 2.0),
                    ),
                    child: DropdownButton<String>(
                        dropdownColor: AppColors.secondaryColor,
                        style: const TextStyle(
                          color: AppColors.backgroundColor,
                        ),
                        value: searchFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            searchFilter = newValue!;
                          });
                          fetchData();
                        },
                        items: <String>['Nom', 'Prenom']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.large),
                            ),
                          );
                        }).toList(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppColors.white),
                        isExpanded: true,
                        underline: const SizedBox()),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Gestion des Professeurs",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
                fontSize: FontSize.large),
          ),
          Expanded(
              child: StreamBuilder<List<dynamic>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: LoadingAnimationWidget.hexagonDots(
                              color: AppColors.secondaryColor, size: 200));
                    } else if (snapshot.hasError) {
                      return Text('Erreur : ${snapshot.error}');
                    } else {
                      List<dynamic>? profs = snapshot.data;
                      if (profs!
                          .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                      {
                        return const SingleChildScrollView(
                          child: NoResultWidget(),
                        );
                      } else {
                        return ListView.builder(
                            itemCount: profs.length,
                            itemBuilder: (context, index) {
                              final prof = profs[index];

                              return ListTile(
                                title:
                                    Text('${prof["nom"]}  ${prof["prenom"]}'),
                                subtitle: Text(
                                  'Num : ${prof["phone"]}',
                                  style: const TextStyle(
                                      color: AppColors.secondaryColor,
                                      fontSize: FontSize.small),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Naviguez vers la page de modification en passant l'ID du prof
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfPage(
                                                    profId: prof['uid'],
                                                    callback: fetchData,
                                                  )),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppColors.redColor,
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
                                                  "Supprimer le prof",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20.0,
                                                      color: Colors.orange),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                                'Êtes-vous sûr de vouloir supprimer ce prof ? Les cours associés n\'auront plus de prof'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  // Supprimez le prof de Firestore
                                                  await set_Data().deleteProf(
                                                      prof['uid'], context);
                                                  fetchData();
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
                                ),
                              );
                            });
                      }
                    }
                  }))
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 70,
        type: ExpandableFabType.up,
        children: [
          Row(
            children: [
              const Text("Ajouter"),
              const SizedBox(
                width: 10,
              ),
              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => addNewProfPage(
                              callback: fetchData,
                            )),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text("Tous supprimer"),
              const SizedBox(
                width: 10,
              ),
              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.delete_forever),
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
                            "Supprimer tous les profs ? ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      content: const Text(
                          'Êtes-vous sûr de vouloir supprimer tous les profs ? \n Les cours n\'auront plus de profs.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Supprimez les profs de Firestore
                            await set_Data().deleteAllProf(context);
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
          ),
          Row(
            children: [
              const Text("Corbeille"),
              const SizedBox(
                width: 10,
              ),
              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.delete_sweep),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TrashProfPage(
                              callback: fetchData,
                            )),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
