// ignore_for_file: must_be_immutable, file_names, non_constant_identifier_names, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeAttendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/takeAttendanceManualy.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/takeQRattendance.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class ListOfOneCourseSeancePage extends StatefulWidget {
  final dynamic course;

  const ListOfOneCourseSeancePage({super.key, required this.course});
  @override
  State<ListOfOneCourseSeancePage> createState() =>
      _ListOfOneCourseSeancePageState();
}

class _ListOfOneCourseSeancePageState extends State<ListOfOneCourseSeancePage> {
  final BACKEND_URL = dotenv.env['API_URL'];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  Future<void> fetchData() async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(
          '$BACKEND_URL/api/seance/getSeanceData?idCours=${widget.course['idCours']}'));

      if (response.statusCode == 200) {
        List<dynamic> seances = jsonDecode(response.body);
        _streamController.add(seances);
      } else {
        throw Exception('Erreur lors de la récupération des seances');
      }
    } catch (e) {
      // Gérer les erreurs ici
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de récupérer les séances. Erreur:$e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    initializeDateFormatting('fr');
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Gestion des séances',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.medium,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WarningWidget(
                            title: "Information",
                            content:
                                "Un point vert indique qu'une séance de présence QR code est en cours et n'a pas été arrêtée !",
                            height: 160);
                      });
                },
                icon: const Icon(Icons.info)),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestion des séances",
                  style: GoogleFonts.poppins(
                      color: AppColors.textColor,
                      fontSize: FontSize.xxLarge,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    "Prenez ici vos présences",
                    style: GoogleFonts.poppins(
                        color: AppColors.primaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                    height: MediaQuery.of(context).size.height - 180,
                    child: StreamBuilder(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: LoadingAnimationWidget.hexagonDots(
                                color: AppColors.secondaryColor, size: 200),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Erreur : ${snapshot.error}');
                        } else {
                          List<dynamic>? seances = snapshot.data;
                          if (seances!.isEmpty) {
                            return const SingleChildScrollView(
                              child: NoResultWidget(),
                            );
                          } else {
                            return ListView.builder(
                                itemCount: seances.length,
                                itemBuilder: (context, index) {
                                  final seance = seances[index];
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: AppColors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30.0, right: 30),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              ExpandablePanel(
                                                  header: Row(
                                                    children: [
                                                      Text(
                                                        DateFormat(
                                                                'EEEE, d MMM yy, hh:mm',
                                                                'fr')
                                                            .format(DateTime
                                                                    .parse(seance[
                                                                        'dateSeance'])
                                                                .toLocal())
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                            color: AppColors
                                                                .secondaryColor,
                                                            fontSize:
                                                                FontSize.small,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                        softWrap: true,
                                                        maxLines: 2,
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Container(
                                                        child: seance[
                                                                    'isActive'] ==
                                                                1
                                                            ? const Icon(
                                                                size: 10,
                                                                Icons.circle,
                                                                color: AppColors
                                                                    .greenColor,
                                                              )
                                                            : const Icon(
                                                                size: 10,
                                                                Icons.circle,
                                                                color: AppColors
                                                                    .redColor),
                                                      )
                                                    ],
                                                  ),
                                                  collapsed: Column(
                                                    children: [
                                                      Text(
                                                        "${widget.course['nomCours']} - ${widget.course['niveau']} ",
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize:
                                                                FontSize.medium,
                                                            color: AppColors
                                                                .textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      seance['presenceTookOnce'] ==
                                                              0
                                                          ? const Text(
                                                              "Aucune présence effectuée",
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            )
                                                          : const Text(
                                                              "Une présence a été effectuée sur cette séance",
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            )
                                                    ],
                                                  ),
                                                  expanded: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      seance['presenceTookOnce'] ==
                                                              0
                                                          ? const Text(
                                                              "Aucune présence effectuée",
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            )
                                                          : GFButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              SeeSeanceAttendanceProf(
                                                                                seance: seance,
                                                                                course: widget.course,
                                                                              )),
                                                                );
                                                              },
                                                              text:
                                                                  "Consulter la présence",
                                                              textStyle: const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  fontSize:
                                                                      FontSize
                                                                          .large,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              shape:
                                                                  GFButtonShape
                                                                      .pills,
                                                              fullWidthButton:
                                                                  true,
                                                            ),
                                                      GFButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TakeManualAttendance(
                                                                          seance:
                                                                              seance,
                                                                          course:
                                                                              widget.course,
                                                                          callback:
                                                                              fetchData,
                                                                        )),
                                                          );
                                                        },
                                                        text:
                                                            "PRESENCE MANUELLE",
                                                        textStyle:
                                                            const TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                                fontSize:
                                                                    FontSize
                                                                        .large,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        shape:
                                                            GFButtonShape.pills,
                                                        fullWidthButton: true,
                                                      ),
                                                      GFButton(
                                                        onPressed: () async {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TakeQrAttendancePage(
                                                                          seance:
                                                                              seance,
                                                                          callback:
                                                                              fetchData,
                                                                        )),
                                                          );
                                                        },
                                                        text:
                                                            "PRESENCE CODE QR",
                                                        textStyle:
                                                            const TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                                fontSize:
                                                                    FontSize
                                                                        .large,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        shape:
                                                            GFButtonShape.pills,
                                                        fullWidthButton: true,
                                                      ),
                                                      GFButton(
                                                        color: GFColors.DANGER,
                                                        onPressed: () async {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: const Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    "Supprimer la séance",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15.0,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ],
                                                              ),
                                                              content: const Text(
                                                                  'Êtes-vous sûr de vouloir supprimer cette séance ?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: const Text(
                                                                      'Annuler'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await set_Data().deleteSeance(
                                                                        seance[
                                                                            'idSeance'],
                                                                        context);
                                                                    fetchData();
                                                                  },
                                                                  child: const Text(
                                                                      'Supprimer'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        text:
                                                            "Supprimer la séance",
                                                        textStyle:
                                                            const TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                                fontSize:
                                                                    FontSize
                                                                        .large,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        shape:
                                                            GFButtonShape.pills,
                                                        fullWidthButton: true,
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  );
                                });
                          }
                        }
                      },
                    )),
              ],
            ),
          ),
        ));
  }
}
