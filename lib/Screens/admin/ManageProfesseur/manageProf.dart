// ignore_for_file: use_build_context_synchronously, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/addNewProf.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/prof_trashed.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/edit_Prof.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
                ),
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
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('prof')
                      .where('statut', isEqualTo: "1")
                      .where(searchFilter.toLowerCase().trim(),
                          isGreaterThanOrEqualTo: searchText.toUpperCase())
                      .where(searchFilter.toLowerCase().trim(),
                          isLessThanOrEqualTo:
                              '${searchText.toUpperCase()}\uf8ff')
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
                                subtitle: Text(
                                  'Num : ${profData["phone"]}',
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
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.hexagonDots(
                            color: AppColors.secondaryColor, size: 200),
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
                        builder: (context) => const TrashProfPage()),
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
