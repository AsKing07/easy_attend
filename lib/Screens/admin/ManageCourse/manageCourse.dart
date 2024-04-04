// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/addNewCourse.dart';
import 'package:easy_attend/Screens/admin/ManageCourse/editCourse.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.secondaryColor,
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cours')
                .where('nomCours',
                    isGreaterThanOrEqualTo: searchText.toUpperCase())
                .where('nomCours',
                    isLessThanOrEqualTo: searchText.toUpperCase() + '\uf8ff')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const NoResultWidget();
                } else {
                  final cours = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: cours.length,
                    itemBuilder: (contex, index) {
                      final cour = cours[index];
                      final courData = cour.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(courData['nomCours']),
                        subtitle: Text(
                          courData['idCours'],
                          style:
                              const TextStyle(color: AppColors.secondaryColor),
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
                                      builder: (context) =>
                                          EditCoursePage(id: cour.id)),
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
                                          await set_Data()
                                              .deleteCours(cour.id, context);
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
              } else if (snapshot.hasError) {
                Helper().ErrorMessage(context);
                return SizedBox();
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
                        builder: (context) => const AddNewCoursePage()),
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
