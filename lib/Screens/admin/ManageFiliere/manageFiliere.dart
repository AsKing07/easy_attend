// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/addNewFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/editFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/filiere_trashed.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageFilierePage extends StatefulWidget {
  const ManageFilierePage({super.key});

  @override
  _ManageFilierePageState createState() => _ManageFilierePageState();
}

class _ManageFilierePageState extends State<ManageFilierePage> {
  String searchText = '';

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
            child: SearchBar(
              leading: const Icon(Icons.search),
              hintText: "Rechercher",
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Gestion des filières",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
                fontSize: FontSize.large),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('filiere')
                  .where('statut', isEqualTo: "1")
                  .where('nomFiliere',
                      isGreaterThanOrEqualTo: searchText.toUpperCase())
                  .where('nomFiliere',
                      isLessThanOrEqualTo: '${searchText.toUpperCase()}\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs
                      .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                  {
                    return const NoResultWidget();
                  } else {
                    final filieres = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: filieres.length,
                      itemBuilder: (context, index) {
                        final filiere = filieres[index];
                        final filiereData =
                            filiere.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(filiereData['nomFiliere']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Naviguez vers la page de modification en passant l'ID de la filière
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ModifierFilierePage(
                                                filiereId: filiere.id)),
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
                                            "Supprimer la filière",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer cette filière ? \n Cela entraînera la supression automatique des \n cours et étudiants associés à cette filière.'),
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
                                            await set_Data().deleteFiliere(
                                                filiere.id, context);
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
                  return const SizedBox();
                } else {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.secondaryColor, size: 200),
                  );
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
                        builder: (context) => const addNewFilierePage()),
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
                            "Supprimer toutes les filières",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.orange),
                          ),
                        ],
                      ),
                      content: const Text(
                          'Êtes-vous sûr de vouloir supprimer toutes les filières ? \n Cela entraînera la supression automatique des \n cours et étudiants associés à cette filière.'),
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
                            await set_Data().deleteAllFiliere(context);
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
                        builder: (context) => const TrashFilierePage()),
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
