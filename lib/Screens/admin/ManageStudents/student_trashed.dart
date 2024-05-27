// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class TrashStudentPage extends StatefulWidget {
  final Function() callback;

  const TrashStudentPage({super.key, required this.callback});

  @override
  State<TrashStudentPage> createState() => _TrashStudentPageState();
}

class _TrashStudentPageState extends State<TrashStudentPage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  void fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('$BACKEND_URL/api/student/getInactifStudentData'));
      if (response.statusCode == 200) {
        List<dynamic> students = jsonDecode(response.body);
        _streamController.add(students);
      } else {
        throw Exception('Erreur lors de la récupération des filières');
      }
    } catch (e) {
      // Gérer les erreurs ici
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
                child: StreamBuilder(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const NoResultWidget();
                  } else {
                    final etudiants = snapshot.data!;
                    return ListView.builder(
                        itemCount: etudiants.length,
                        itemBuilder: (context, index) {
                          final etudiant = etudiants[index];

                          return ListTile(
                            title: Text(
                                '${etudiant['nom']}  ${etudiant['prenom']}'),
                            subtitle: Text(
                              '${etudiant['matricule']}  ${etudiant['filiere']} ${etudiant['niveau']}',
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
                                                      etudiant['uid'], context);
                                              widget.callback();
                                              fetchData();
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
