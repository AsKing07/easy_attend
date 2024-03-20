import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrashFilierePage extends StatefulWidget {
  @override
  _TrashFilierePageState createState() => _TrashFilierePageState();
}

class _TrashFilierePageState extends State<TrashFilierePage> {
  var allfiliere = [];
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Corbeille des filières',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('filiere')
                  .where('statut', isEqualTo: "0")
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
                                icon: const Icon(
                                  Icons.restore,
                                  color: AppColors.greenColor,
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
                                            "Restaurer la filière",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir restaurer cette filière ?  '),
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
                                                .restoreFiliere(
                                                    filiere.id, context);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Restaurer'),
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
    );
  }
}
