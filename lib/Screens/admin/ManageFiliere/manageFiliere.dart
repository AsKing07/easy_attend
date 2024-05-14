// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/addNewFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/editFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/filiere_trashed.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageFilierePage extends StatefulWidget {
  const ManageFilierePage({Key? key}) : super(key: key);

  @override
  _ManageFilierePageState createState() => _ManageFilierePageState();
}

class _ManageFilierePageState extends State<ManageFilierePage> {
  final TextEditingController _searchController = TextEditingController();
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

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
          '$BACKEND_URL/api/filiere/getFiliereData?search=${_searchController.text}'));
      if (response.statusCode == 200) {
        List<dynamic> filieres = jsonDecode(response.body);
        _streamController.add(filieres);
        print(filieres);
      } else {
        throw Exception('Erreur lors de la récupération des filières');
      }
    } catch (e) {
      // Gérer les erreurs ici
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.secondaryColor,
            height: 80,
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: MediaQuery.of(context).size.width >= 1024
                  ? MediaQuery.of(context).size.width * 0.2
                  : MediaQuery.of(context).size.width >= 600
                      ? MediaQuery.of(context).size.width * 0.05
                      : 10,
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.white,
                ),
                hintText: "Rechercher",
                hintStyle: TextStyle(color: AppColors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.white),
                ),
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
          const SizedBox(height: 10),
          const Text(
            "Gestion des filières",
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
                        color: AppColors.secondaryColor, size: 100),
                  );
                } else if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                } else {
                  List<dynamic>? filieres = snapshot.data;
                  if (filieres!.isEmpty) {
                    return const SingleChildScrollView(
                      child: NoResultWidget(),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: filieres.length,
                      itemBuilder: (context, index) {
                        final filiere = filieres[index];
                        return ListTile(
                          title: Text(filiere['nomFiliere']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ModifierFilierePage(
                                        filiereId: filiere['idFiliere'],
                                        callback: fetchData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: AppColors.redColor),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Row(
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.orange),
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
                                              filiere['idFiliere'],
                                              context,
                                            );
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
                      },
                    );
                  }
                }
              },
            ),
          ),
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
                      builder: (context) => addNewFilierePage(
                        callback: fetchData,
                      ),
                    ),
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
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            "Supprimer toutes les filières",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Êtes-vous sûr de vouloir supprimer toutes les filières ? \n Cela entraînera la supression automatique des \n cours et étudiants associés à cette filière.',
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
                            // Supprimez les filières de Firestore
                            await set_Data().deleteAllFiliere(context);
                            fetchData(); // Recharger les données après la suppression
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
                      builder: (context) => TrashFilierePage(
                        callback: fetchData,
                      ),
                    ),
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
