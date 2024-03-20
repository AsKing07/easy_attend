import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/addNewFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/editFiliere.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/filiere_trashed.dart';
import 'package:easy_attend/Screens/admin/adminMethods/set_data.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ManageFilierePage extends StatefulWidget {
  @override
  _ManageFilierePageState createState() => _ManageFilierePageState();
}

class _ManageFilierePageState extends State<ManageFilierePage> {
  var allfiliere = [];
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
              leading: Icon(
                Icons.search,
              ),
              hintText: "Rechercher",
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('filiere')
                  .where('statut', isEqualTo: "1")
                  .where('nomFiliere',
                      isGreaterThanOrEqualTo: searchText.toUpperCase())
                  .where('nomFiliere',
                      isLessThanOrEqualTo: searchText.toUpperCase() + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs
                      .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                  {
                    return NoResultWidget();
                  } else {
                    final filieres = snapshot.data!.docs;
                    allfiliere = filieres;
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
                                            await set_data_Admin()
                                                .deleteFiliere(
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
                  // return
                  //  Text('Erreur: ${snapshot.error}'
                  //  );
                  return myErrorWidget(
                      content: "Une erreur innatendue s'est produite",
                      height: 40);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
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
                        builder: (context) => addNewFilierePage()),
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
                            await set_data_Admin().deleteAllFiliere(context);
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
                    MaterialPageRoute(builder: (context) => TrashFilierePage()),
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
