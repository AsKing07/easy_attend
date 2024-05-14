// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/my_error_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class TrashFilierePage extends StatefulWidget {
  final Function() callback;

  const TrashFilierePage({super.key, required this.callback});

  @override
  _TrashFilierePageState createState() => _TrashFilierePageState();
}

class _TrashFilierePageState extends State<TrashFilierePage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();
  void fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('$BACKEND_URL/api/global/getInactifFiliereData'));
      if (response.statusCode == 200) {
        List<dynamic> filieres = jsonDecode(response.body);
        _streamController.add(filieres);
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
            child: StreamBuilder<List<dynamic>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!
                      .isEmpty) // Afficher un message si aucun résultat n'est trouvé
                  {
                    return const NoResultWidget();
                  } else {
                    List<dynamic>? filieres = snapshot.data;

                    return ListView.builder(
                      itemCount: filieres!.length,
                      itemBuilder: (context, index) {
                        final filiere = filieres[index];

                        return ListTile(
                          title: Text(filiere['nomFiliere']),
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
                                          'Êtes-vous sûr de vouloir restaurer cette filière ?  Les étudiants et cours seront également restaurés! '),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Restaurer la filière de Firestore
                                            await set_Data().restoreFiliere(
                                                filiere['idFiliere'], context);
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
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return myErrorWidget(
                      content: "Une erreur innatendue s'est produite",
                      height: 40);
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
    );
  }
}
