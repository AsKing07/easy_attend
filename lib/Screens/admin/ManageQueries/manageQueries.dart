// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ManageQueriesPage extends StatefulWidget {
  const ManageQueriesPage({Key? key}) : super(key: key);

  @override
  State<ManageQueriesPage> createState() => _ManageQueriesPageState();
}

class _ManageQueriesPageState extends State<ManageQueriesPage> {
  List<Map<String, String>> statutDisponibles = [
    {"nom": "Approuvé", "valeur": "1"},
    {"nom": "Refusé", "valeur": "0"},
    {"nom": "En attente", "valeur": "2"}
  ];
  Map<String, dynamic> filter = {
    'nom': '',
    'valeur': '',
  };

  String selectedFilter = '';
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          '$BACKEND_URL/api/requete/getRequestData?filtre=${filter['valeur']}'));
      if (response.statusCode == 200) {
        List<dynamic> requete = jsonDecode(response.body);
        for (var item in requete) {
          item['isExpanded'] = false; // Initialize isExpanded to false
        }
        _streamController.add(requete);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de récupérer les requêtes. '),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les requêtes. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getAuteur(String input) {
    List<String> words = input.split(' ');
    return '${words[0]} ${words[1]}';
  }

  String getDetailsExceptAuteur(String input) {
    List<String> words = input.split(' ');
    List<String> remainingWords = words.sublist(3);
    return remainingWords.join(' ');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Gestion des requêtes",
                style: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontSize: FontSize.xxLarge,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  "Analysez ici vos requêtes",
                  style: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: !screenSize().isWeb() ? 8 : 32,
                children: statutDisponibles.map((item) {
                  return FilterChip(
                    label: Text(item['nom'] as String),
                    selected: selectedFilter == item['valeur'],
                    onSelected: (bool selected) {
                      setState(() {
                        selectedFilter =
                            selected ? item['valeur'] as String : '';
                        filter['nom'] = item['nom'] as String;
                        filter['valeur'] = selectedFilter;
                        fetchData();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height - 180,
                child: StreamBuilder<List<dynamic>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.hexagonDots(
                            color: AppColors.secondaryColor, size: 100),
                      );
                    } else if (snapshot.hasError) {
                      return errorWidget(error: snapshot.error.toString());
                    } else {
                      List<dynamic>? requetes = snapshot.data;
                      if (requetes!.isEmpty) {
                        return const SingleChildScrollView(
                          child: NoResultWidget(),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: requetes.length,
                          itemBuilder: (context, index) {
                            final query = requetes[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      query['type'].toString(),
                                      style: const TextStyle(
                                          color: AppColors.secondaryColor,
                                          fontSize: FontSize.medium,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    trailing: query['statut'] == "1"
                                        ? const Icon(Icons.check,
                                            color: AppColors.greenColor)
                                        : query['statut'] == "2"
                                            ? const Icon(Icons.sync,
                                                color: AppColors.studColor)
                                            : const Icon(Icons.cancel,
                                                color: AppColors.redColor),
                                    onTap: () {
                                      setState(() {
                                        query['isExpanded'] =
                                            !query['isExpanded'];
                                      });
                                    },
                                  ),
                                  if (query['isExpanded'])
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Auteur : ${getAuteur(query['details'])}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Détails: \n  ${getDetailsExceptAuteur(query['details'])}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: GFButton(
                                                  color: AppColors.greenColor,
                                                  onPressed: () async {
                                                    await set_Data()
                                                        .approuverRequete(
                                                            query['idRequete'],
                                                            context);
                                                    setState(() {
                                                      selectedFilter = "1";
                                                      filter['valeur'] = "1";
                                                      fetchData();
                                                    });
                                                  },
                                                  text: "Approuver",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: GFButton(
                                                  color: AppColors.redColor,
                                                  onPressed: () async {
                                                    await set_Data()
                                                        .desapprouverRequete(
                                                            query['idRequete'],
                                                            context);
                                                    setState(() {
                                                      selectedFilter = "0";
                                                      filter['valeur'] = "0";
                                                      fetchData();
                                                    });
                                                  },
                                                  text: "Rejeter",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: GFButton(
                                                  color: AppColors.studColor,
                                                  onPressed: () async {
                                                    await set_Data()
                                                        .mettreEnAttenteRequete(
                                                            query['idRequete'],
                                                            context);
                                                    setState(() {
                                                      selectedFilter = "2";
                                                      filter['valeur'] = "2";
                                                      fetchData();
                                                    });
                                                  },
                                                  text: "En attente",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
