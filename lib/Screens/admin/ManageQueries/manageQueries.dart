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
import 'package:expandable/expandable.dart';
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
      // Gérer les erreurs ici
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
    List<String> words = input.split(' '); // Split the input string by space

    return '${words[0]} ${words[1]}'; // Concatenate the first two words
  }

  String getDetailsExceptAuteur(String input) {
    List<String> words = input.split(' '); // Split the input string by space

    List<String> remainingWords =
        words.sublist(3); // Get sublist starting from index 3
    return remainingWords
        .join(' '); // Join the remaining words back into a string
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
          padding: const EdgeInsets.all(30.0),
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
              const SizedBox(
                height: 16,
              ),
              // ignore: sized_box_for_whitespace
              Container(
                height: MediaQuery.of(context).size.height -
                    180, // Définir la hauteur en fonction de la taille de l'écran
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

                              return Column(
                                children: [
                                  Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                              color: AppColors.shadow,
                                              blurRadius: 100,
                                              spreadRadius: 5,
                                              offset: Offset(0, 60)),
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.white,
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0, right: 30),
                                          child: Column(children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            ExpandablePanel(
                                              header: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 160,
                                                    child: Text(
                                                      query['type'].toString(),
                                                      overflow:
                                                          TextOverflow.visible,
                                                      maxLines: null,
                                                      softWrap: true,
                                                      style: const TextStyle(
                                                          color: AppColors
                                                              .secondaryColor,
                                                          fontSize:
                                                              FontSize.medium,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: query['statut'] ==
                                                            "1"
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: AppColors
                                                                .greenColor,
                                                          )
                                                        : query['statut'] == "2"
                                                            ? const Icon(
                                                                Icons.sync,
                                                                color: AppColors
                                                                    .studColor)
                                                            : const Icon(
                                                                Icons.cancel,
                                                                color: AppColors
                                                                    .redColor),
                                                  )
                                                ],
                                              ),
                                              collapsed: Text(
                                                query['sujet'].toString(),
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: FontSize.medium,
                                                    color: AppColors.textColor,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              expanded: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Auteur : ${getAuteur(query['details'])}",
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .textColor,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Détails: \n  ${getDetailsExceptAuteur(query['details'])}",
                                                      softWrap: true,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .textColor,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GFButton(
                                                      onPressed: () async {
                                                        // Approuver la requete
                                                        await set_Data()
                                                            .approuverRequete(
                                                                query[
                                                                    'idRequete'],
                                                                context);
                                                        setState(() {
                                                          selectedFilter = "1";
                                                          filter['valeur'] =
                                                              "1";
                                                          fetchData();
                                                        });
                                                      },
                                                      text: "Approuver",
                                                      textStyle:
                                                          const TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: FontSize
                                                                  .large,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      shape:
                                                          GFButtonShape.pills,
                                                      fullWidthButton: true,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GFButton(
                                                      onPressed: () async {
                                                        // Désapprouver la requete
                                                        await set_Data()
                                                            .desapprouverRequete(
                                                                query[
                                                                    'idRequete'],
                                                                context);
                                                        setState(() {
                                                          selectedFilter = "0";
                                                          filter['valeur'] =
                                                              "0";
                                                          fetchData();
                                                        });
                                                      },
                                                      text: "Désapprouver",
                                                      textStyle:
                                                          const TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: FontSize
                                                                  .large,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      shape:
                                                          GFButtonShape.pills,
                                                      fullWidthButton: true,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GFButton(
                                                      onPressed: () async {
                                                        // mettre en attente la requete
                                                        await set_Data()
                                                            .mettreEnAttenteRequete(
                                                                query[
                                                                    'idRequete'],
                                                                context);
                                                        setState(() {
                                                          selectedFilter = "2";
                                                          filter['valeur'] =
                                                              "2";
                                                          fetchData();
                                                        });
                                                      },
                                                      text: "Mettre en attente",
                                                      textStyle:
                                                          const TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontSize: FontSize
                                                                  .large,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      shape:
                                                          GFButtonShape.pills,
                                                      fullWidthButton: true,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ]),
                                            ),
                                          ]))),
                                  const SizedBox(
                                    height: 10,
                                  )
                                ],
                              );
                            });
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
