import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/addNewProf.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/prof_trashed.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/edit_Prof.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class ManageProf extends StatefulWidget {
  const ManageProf({super.key});

  @override
  State<ManageProf> createState() => _ManageProfState();
}

class _ManageProfState extends State<ManageProf> {
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
                DropdownButton<String>(
                  value: searchFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      searchFilter = newValue!;
                    });
                  },
                  items: <String>['Nom', 'Prenom']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
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
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('prof')
                      .where('statut', isEqualTo: "1")
                      .where(searchFilter.toLowerCase().trim(),
                          isGreaterThanOrEqualTo: searchText.toUpperCase())
                      .where(searchFilter.toLowerCase().trim(),
                          isLessThanOrEqualTo:
                              searchText.toUpperCase() + '\uf8ff')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs
                          .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                      {
                        return const NoResultWidget();
                      } else {
                        final profs = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: profs.length,
                            itemBuilder: (context, index) {
                              final prof = profs[index];
                              final profData =
                                  prof.data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(
                                    '${profData["nom"]}  ${profData["prenom"]}'),
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
                                                    profId: prof.id,
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
                                                      prof.id, context);
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
                    } else if (snapshot.hasError) {
                      return myErrorWidget(
                          content: "Une erreur innatendue s'est produite",
                          height: 150);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                        builder: (context) => const addNewProfPage()),
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
                            // // Supprimez les profs de Firestore
                            // await set_Data().deleteAllProf(context);
                            // Navigator.of(context).pop();
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
                    MaterialPageRoute(builder: (context) => TrashProfPage()),
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
