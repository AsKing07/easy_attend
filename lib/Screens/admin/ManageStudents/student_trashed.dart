// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TrashStudentPage extends StatefulWidget {
  const TrashStudentPage({super.key});

  @override
  State<TrashStudentPage> createState() => _TrashStudentPageState();
}

class _TrashStudentPageState extends State<TrashStudentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Corbeille des étudiants',
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
                  .collection('etudiant')
                  .where('statut', isEqualTo: '0')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
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
                                              "Restaurer l' étudiant",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  color: Colors.orange),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                            'Êtes-vous sûr de vouloir restaurer cet étudiant ?  '),
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
                                                  .restoreOneStudent(
                                                      etudiant.id, context);
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
                  return const SizedBox();
                } else {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.secondaryColor, size: 200),
                  );
                }
              },
            ))
          ],
        ));
  }
}
