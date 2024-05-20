// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addNewStudent.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addStudentFromExcel.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/edit_Student.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/student_trashed.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageStudentPage extends StatefulWidget {
  const ManageStudentPage({super.key});

  @override
  State<ManageStudentPage> createState() => _ManageStudentPageState();
}

class _ManageStudentPageState extends State<ManageStudentPage> {
  final TextEditingController _searchController = TextEditingController();
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  String searchFilter = 'Nom';
  List<Filiere> Allfilieres = [];
  Filiere? _selectedFiliere;
  var _selectedNiveau;

  Future<void> loadAllActifFilieres() async {
    List<dynamic> docsFiliere = await get_Data().getActifFiliereData();
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      print(doc);
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

  void _onSearchChanged() {
    fetchData();
  }

  Future<void> fetchData() async {
    http.Response response;
    try {
      if (_selectedFiliere != null) {
        if (_selectedNiveau != null) {
          response = await http.get(Uri.parse(
              '$BACKEND_URL/api/student/getStudentData?search=${_searchController.text}&idFiliere=${_selectedFiliere?.idDoc}&niveau=$_selectedNiveau'));
        } else {
          response = await http.get(Uri.parse(
              '$BACKEND_URL/api/student/getStudentData?search=${_searchController.text}&idFiliere=${_selectedFiliere?.idDoc}'));
        }
      } else {
        response = await http.get(Uri.parse(
            '$BACKEND_URL/api/student/getStudentData?search=${_searchController.text}'));
      }
      // final response = await http.get(Uri.parse(
      //     '$BACKEND_URL/api/global/getStudentData?search=${_searchController.text}&filtre=$searchFilter'));

      if (response.statusCode == 200) {
        List<dynamic> students = jsonDecode(response.body);
        _streamController.add(students);
        print(students);
      } else {
        throw Exception('Erreur lors de la récupération des étudiants');
      }
    } catch (e) {
      // Gérer les erreurs ici
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    loadAllActifFilieres();

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
                          fontSize: FontSize.xSmall),
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
                            style: TextStyle(
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
                IconButton(
                  color: AppColors.white,
                  iconSize: 50,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return WarningWidget(
                          title: "Information",
                          content:
                              "Vous pouvez rechercher un étudiant à l'aide de son nom, prénom ou matricule",
                          height: 150,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.info),
                ),
                // Expanded(
                //     child: Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   decoration: BoxDecoration(
                //     color: AppColors.secondaryColor,
                //     borderRadius: BorderRadius.circular(8.0),
                //     border: Border.all(color: AppColors.white, width: 2.0),
                //   ),
                //   child: DropdownButton<String>(
                //       dropdownColor: AppColors.secondaryColor,
                //       style: const TextStyle(
                //         color: AppColors.backgroundColor,
                //       ),
                //       value: searchFilter,
                //       onChanged: (String? newValue) {
                //         setState(() {
                //           searchFilter = newValue!;
                //         });
                //       },
                //       items: <String>['Nom', 'Prenom', 'Filiere', 'Matricule']
                //           .map<DropdownMenuItem<String>>((String value) {
                //         return DropdownMenuItem<String>(
                //           value: value,
                //           child: Text(
                //             value,
                //             style: const TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: FontSize.large),
                //           ),
                //         );
                //       }).toList(),
                //       icon: const Icon(Icons.arrow_drop_down,
                //           color: AppColors.white),
                //       isExpanded: true,
                //       underline: const SizedBox()),
                // ))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Gestion des Etudiants",
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
                List<dynamic>? students = snapshot.data;
                if (students!
                    .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                {
                  return const SingleChildScrollView(
                    child: NoResultWidget(),
                  );
                } else {
                  return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final etudiant = students[index];

                        return ListTile(
                          title:
                              Text('${etudiant['nom']}  ${etudiant['prenom']}'),
                          subtitle: Text(
                            '${etudiant['matricule']}   ${etudiant['niveau']}',
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
                                  // Naviguez vers la page de modification en passant l'ID
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditStudentPage(
                                              studentId: etudiant['uid'],
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
                                            "Supprimer l' étudiant",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer cet étudiant?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Changer le statut de l'étudiant dans Firestore
                                            await set_Data().deleteOneStudent(
                                                etudiant['uid'], context);
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
                        builder: (context) => addNewStudentPage(
                              callback: fetchData,
                            )),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text("Ajouter depuis un fichier"),
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
                        builder: (context) => AddStudentFromExcel(
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
                            "Tous les Supprimer ? ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      content: const Text(
                          'Êtes-vous sûr de vouloir supprimer tous les étudiants ? '),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Supprimez les étudiants de Firestore
                            await set_Data().deleteAllStudents(context);
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
                        builder: (context) =>
                            TrashStudentPage(callback: fetchData)),
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
