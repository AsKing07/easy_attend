// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addNewStudent.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addStudentFromExcel.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/edit_Student.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/student_trashed.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ManageStudentPage extends StatefulWidget {
  const ManageStudentPage({super.key});

  @override
  State<ManageStudentPage> createState() => _ManageStudentPageState();
}

class _ManageStudentPageState extends State<ManageStudentPage> {
  String searchText = '';
  String searchFilter = 'Nom';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.secondaryColor,
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    leading: const Icon(
                      Icons.search,
                    ),
                    hintText: "Rechercher",
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  dropdownColor: AppColors.secondaryColor,
                  style: const TextStyle(
                    color: AppColors.backgroundColor,
                  ),
                  value: searchFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      searchFilter = newValue!;
                    });
                  },
                  items: <String>['Nom', 'Prenom', 'Filiere', 'Matricule']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('etudiant')
                .where('statut', isEqualTo: "1")
                .where(searchFilter.toLowerCase().trim(),
                    isGreaterThanOrEqualTo: searchText.toUpperCase())
                .where(searchFilter.toLowerCase().trim(),
                    isLessThanOrEqualTo: '${searchText.toUpperCase()}\uf8ff')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs
                    .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                {
                  return const NoResultWidget();
                } else {
                  final etudiants = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: etudiants.length,
                      itemBuilder: (context, index) {
                        final etudiant = etudiants[index];
                        final etudiantData =
                            etudiant.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(
                              '${etudiantData['nom']}  ${etudiantData['prenom']}'),
                          subtitle: Text(
                            '${etudiantData['matricule']}  ${etudiantData['filiere']} ${etudiantData['niveau']}',
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
                                              studentId: etudiant.id,
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
                                                fontSize: 20.0,
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
                                                etudiant.id, context);
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
              } else if (snapshot.hasData) {
                return const NoResultWidget();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
                        builder: (context) => const addNewStudentPage()),
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
                        builder: (context) => const AddStudentFromExcel()),
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
                    MaterialPageRoute(builder: (context) => TrashStudentPage()),
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
