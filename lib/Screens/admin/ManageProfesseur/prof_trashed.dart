// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrashProfPage extends StatefulWidget {
  final Function() callback;
  const TrashProfPage({super.key, required this.callback});

  @override
  State<TrashProfPage> createState() => _TrashProfPageState();
}

class _TrashProfPageState extends State<TrashProfPage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  void fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('$BACKEND_URL/api/global/getInactifProfData'));
      if (response.statusCode == 200) {
        List<dynamic> profs = jsonDecode(response.body);
        _streamController.add(profs);
      } else {
        throw Exception('Erreur lors de la récupération des profs');
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
              child: StreamBuilder<List<dynamic>>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!
                    .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                {
                  return const NoResultWidget();
                } else {
                  List<dynamic>? profs = snapshot.data;
                  return ListView.builder(
                      itemCount: profs!.length,
                      itemBuilder: (context, index) {
                        final prof = profs[index];

                        return ListTile(
                          title: Text('${prof['nom']} ${prof['prenom']}'),
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
                                                fontSize: 13.0,
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
                                            // Restaurer le prof
                                            await set_Data().restoreProf(
                                                prof['uid'], context);
                                            fetchData();
                                            widget.callback();

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
      ),
    );
  }
}
