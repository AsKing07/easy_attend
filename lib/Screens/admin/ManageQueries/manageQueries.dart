// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expandable/expandable.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
                child: StreamBuilder<QuerySnapshot>(
                  stream: filter['valeur'] != ""
                      ? FirebaseFirestore.instance
                          .collection('requete')
                          .where('statut', isEqualTo: filter['valeur'])
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('requete')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return const NoResultWidget();
                      } else {
                        final queries = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: queries.length,
                            itemBuilder: (context, index) {
                              final query = queries[index];
                              final queryData =
                                  query.data() as Map<String, dynamic>;

                              return Container(
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                queryData['type'].toString(),
                                                style: const TextStyle(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    fontSize: FontSize.large,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Container(
                                                child: queryData['statut'] ==
                                                        "1"
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: AppColors
                                                            .greenColor,
                                                      )
                                                    : queryData['statut'] == "2"
                                                        ? const Icon(Icons.sync,
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
                                            queryData['sujet'].toString(),
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: FontSize.medium,
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          expanded: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Auteur : ${query['auteur']}",
                                                  softWrap: true,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textColor,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "Détails: \n  ${queryData['details']}",
                                                  softWrap: true,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textColor,
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
                                                            query.id, context);
                                                    setState(() {
                                                      selectedFilter = "1";
                                                      filter['valeur'] = "1";
                                                    });
                                                  },
                                                  text: "Approuver",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
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
                                                            query.id, context);
                                                    setState(() {
                                                      selectedFilter = "0";
                                                      filter['valeur'] = "0";
                                                    });
                                                  },
                                                  text: "Désapprouver",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
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
                                                            query.id, context);
                                                    setState(() {
                                                      selectedFilter = "2";
                                                      filter['valeur'] = "2";
                                                    });
                                                  },
                                                  text: "Mettre en attente",
                                                  textStyle: const TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: FontSize.large,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  shape: GFButtonShape.pills,
                                                  fullWidthButton: true,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ]),
                                        ),
                                      ])));
                            });
                      }
                    } else if (snapshot.hasError) {
                      return const NoResultWidget();
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.hexagonDots(
                            color: AppColors.secondaryColor, size: 200),
                      );
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
