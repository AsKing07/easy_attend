// ignore_for_file: use_build_context_synchronously, file_names, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/addNewCourse.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/editCourse.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  final TextEditingController _searchController = TextEditingController();
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  var _selectedNiveau;

  void _onSearchChanged() {
    fetchData();
  }

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
    http.Response response;
    try {
      if (_selectedFiliere != null) {
        if (_selectedNiveau != null) {
          response = await http.get(Uri.parse(
              '$BACKEND_URL/api/cours/getCoursesData?search=${_searchController.text}&idFiliere=${_selectedFiliere?.idDoc}&niveau=$_selectedNiveau'));
        } else {
          response = await http.get(Uri.parse(
              '$BACKEND_URL/api/cours/getCoursesData?search=${_searchController.text}&idFiliere=${_selectedFiliere?.idDoc}'));
        }
      } else {
        response = await http.get(Uri.parse(
            '$BACKEND_URL/api/cours/getCoursesData?search=${_searchController.text}'));
      }
      if (response.statusCode == 200) {
        List<dynamic> courses = jsonDecode(response.body);
        _streamController.add(courses);
      } else {
        throw Exception('Erreur lors de la récupération des cours');
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les étudiants. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showCourseDetailsDialog(BuildContext context, dynamic course) async {
    final prof = await get_Data().getProfById(course['idProfesseur'], context);
    final fil = await get_Data().getFiliereById(course['idFiliere'], context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(course['nomCours']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sigle: ${course['sigleCours']}'),
              Text('Niveau: ${course['niveau']}'),
              Text('Filière: ${fil['nomFiliere']}'),
              Text('Professeur: ${prof['nom']} ${prof['prenom']}'),
              // Ajoutez d'autres détails du cours ici
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadAllActifFilieres();

    _searchController.addListener(_onSearchChanged);

    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              color: AppColors.secondaryColor,
              height: 75,
              width: double.infinity,
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
                    child:
                        //Dropdown Filieres
                        DropdownButtonFormField<Filiere>(
                      dropdownColor: AppColors.secondaryColor,
                      style: const TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: FontSize.small),
                      value: _selectedFiliere,
                      elevation: 18,
                      onChanged: (Filiere? value) {
                        setState(() {
                          _selectedFiliere = value!;
                          _selectedNiveau = null;
                        });
                        fetchData();
                      },
                      items: Allfilieres.map<DropdownMenuItem<Filiere>>(
                          (Filiere value) {
                        return DropdownMenuItem<Filiere>(
                          value: value,
                          child: Text(
                            value.nomFiliere,
                            style: const TextStyle(
                                fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.white),
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(color: AppColors.white),
                        labelText: 'Filière',
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.white, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: //Dropdown Niveaux
                        _selectedFiliere != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: AppColors.white, width: 2.0),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedNiveau,
                                  dropdownColor: AppColors.secondaryColor,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedNiveau = value!;
                                      fetchData();
                                    });
                                  },
                                  items: _selectedFiliere!.niveaux
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            color: AppColors.white),
                                      ),
                                    );
                                  }).toList(),
                                  hint: const Text(
                                    'Niveau',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: AppColors.white),
                                  isExpanded: true,
                                  underline:
                                      const SizedBox(), // Supprime la ligne de séparation
                                ),
                              )
                            : const SizedBox(),
                  )
                ],
              )),
          Container(
            color: AppColors.secondaryColor,
            height: 80,
            width: double.infinity,
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
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Gestion des cours",
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
                return errorWidget(error: snapshot.error.toString());
              } else {
                List<dynamic>? cours = snapshot.data;
                if (cours!.isEmpty) {
                  return const SingleChildScrollView(
                    child: NoResultWidget(),
                  );
                } else {
                  final cours = snapshot.data!;
                  return ListView.builder(
                    itemCount: cours.length,
                    itemBuilder: (contex, index) {
                      final cour = cours[index];
                      return ListTile(
                        title: Text(cour['nomCours']),
                        subtitle: Text(
                          cour['sigleCours'],
                          style:
                              const TextStyle(color: AppColors.secondaryColor),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                showCourseDetailsDialog(context, cour);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Naviguez vers la page de modification en passant l'ID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditCoursePage(
                                            id: cour['idCours'],
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
                                          "Supprimer le cours",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                              color: Colors.orange),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                        'Êtes-vous sûr de vouloir supprimer ce cours ?  Cette action est irréversible'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Supprimez la filière de Firestore
                                          await set_Data().deleteCours(
                                              cour['idCours'], context);
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
          ))
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
                        builder: (context) => AddNewCoursePage(
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
                            // Supprimez les filière de Firestore
                            await set_Data().deleteAllCours(context);
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
        ],
      ),
    );
  }
}
