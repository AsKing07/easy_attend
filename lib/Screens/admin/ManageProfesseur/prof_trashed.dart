import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';

class TrashProfPage extends StatefulWidget {
  const TrashProfPage({super.key});

  @override
  State<TrashProfPage> createState() => _TrashProfPageState();
}

class _TrashProfPageState extends State<TrashProfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Corbeille des profs',
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
                .collection("prof")
                .where('statut', isEqualTo: '0')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs
                    .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                {
                  return NoResultWidget();
                } else {
                  final profs = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: profs.length,
                      itemBuilder: (context, index) {
                        final prof = profs[index];
                        final profData = prof.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(profData['nom']),
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
                                            "Restaurer le professeur",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir restaurer ce professeur ?  '),
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
                                                .restoreProf(prof.id, context);
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
                      });
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
    );
  }
}
