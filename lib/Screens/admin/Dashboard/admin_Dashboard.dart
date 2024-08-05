// ignore_for_file: file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Widgets/errorWidget2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late dynamic admin;
  bool dataIsLoaded = false;

  void loadAdmin() async {
    final x = await get_Data().loadCurrentAdminData();
    setState(() {
      admin = x;
      dataIsLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return !dataIsLoaded
              ? Center(
                  child: LoadingAnimationWidget.hexagonDots(
                      color: AppColors.secondaryColor, size: 100),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: screenSize().isWeb()
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 35, 0, 10),
                        child: Column(
                          crossAxisAlignment: screenSize().isWeb()
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue ${admin['nom']} ${admin['prenom']}',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor,
                                fontSize: FontSize.xxLarge,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Consulter les données actuelles',
                              style: GoogleFonts.poppins(
                                color: AppColors.secondaryColor,
                                fontSize: FontSize.medium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20.0,
                            runSpacing: 20.0,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width:
                                        constraints.maxWidth > 800 ? 320 : 160,
                                    height: 200,
                                    child: FutureBuilder(
                                      future: get_Data()
                                          .getActifStudentData(context),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: LoadingAnimationWidget
                                                .hexagonDots(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    size: 50),
                                          );
                                        } else {
                                          if (snapshot.hasError) {
                                            return errorWidget(
                                                error:
                                                    snapshot.error.toString());
                                            // return
                                            // const Column(
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   children: [
                                            //     Icon(
                                            //       Icons.error_outline_outlined,
                                            //       color: Colors.red,
                                            //       size: 50,
                                            //     ),
                                            //     Text(
                                            //       'Oups... quelque chose s\'est mal passé',
                                            //     ),
                                            //   ],
                                            // );
                                            // Center(
                                            //   child: Text(
                                            //       'Erreur lors de la récupération des étudiants actifs: ${snapshot.error}'),
                                            // );
                                          } else {
                                            List<dynamic> students =
                                                snapshot.data;
                                            return Card(
                                              color: Colors.white,
                                              elevation: 8.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons.people,
                                                        color:
                                                            AppColors.studColor,
                                                        size: 70.0,
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      const Text(
                                                        "Etudiants",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize:
                                                              FontSize.xxLarge,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10.0),
                                                      Text(
                                                        students.length
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 25.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        constraints.maxWidth > 800 ? 320 : 160,
                                    height: 200,
                                    child: FutureBuilder(
                                      future: get_Data()
                                          .getActifTeacherData(context),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: LoadingAnimationWidget
                                                .hexagonDots(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    size: 50),
                                          );
                                        } else {
                                          if (snapshot.hasError) {
                                            return errorWidget(
                                                error:
                                                    snapshot.error.toString());
                                            // return const Column(
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   children: [
                                            //     Icon(
                                            //       Icons.error_outline_outlined,
                                            //       color: Colors.red,
                                            //       size: 50,
                                            //     ),
                                            //     Text(
                                            //       'Oups... quelque chose s\'est mal passé',
                                            //     ),
                                            //   ],
                                            // );
                                            // Center(
                                            //   child: Text(
                                            //       'Erreur lors de la récupération des étudiants actifs: ${snapshot.error}'),
                                            // );
                                          } else {
                                            List<dynamic> profs = snapshot.data;

                                            return Card(
                                              color: Colors.white,
                                              elevation: 8.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons.person_3,
                                                        color:
                                                            AppColors.profColor,
                                                        size: 70.0,
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      const Text(
                                                        "Professeurs",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize:
                                                              FontSize.xxLarge,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10.0),
                                                      Text(
                                                        profs.length.toString(),
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 25.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: constraints.maxWidth > 800
                                          ? 320
                                          : 160,
                                      height: 200,
                                      child: FutureBuilder(
                                        future: get_Data()
                                            .getActifFiliereData(context),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: LoadingAnimationWidget
                                                  .hexagonDots(
                                                color: AppColors.secondaryColor,
                                                size: 50,
                                              ),
                                            );
                                          } else {
                                            if (snapshot.hasError) {
                                              return errorWidget(
                                                  error: snapshot.error
                                                      .toString());
                                              // const Column(
                                              //   mainAxisSize: MainAxisSize.min,
                                              //   children: [
                                              //     Icon(
                                              //       Icons
                                              //           .error_outline_outlined,
                                              //       color: Colors.red,
                                              //       size: 50,
                                              //     ),
                                              //     Text(
                                              //       'Oups... quelque chose s\'est mal passé',
                                              //     ),
                                              //   ],
                                              // );
                                              // Center(
                                              //   child: Text(
                                              //       'Erreur lors de la récupération des filières actives: ${snapshot.error}'),
                                              // );
                                            } else {
                                              List<dynamic> filiere =
                                                  snapshot.data;
                                              return Card(
                                                color: Colors.white,
                                                elevation: 8.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        const Icon(
                                                          Icons.school,
                                                          color: AppColors
                                                              .filiereColor,
                                                          size: 70.0,
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        const Text(
                                                          "Filières",
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .textColor,
                                                            fontSize: FontSize
                                                                .xxLarge,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10.0,
                                                        ),
                                                        Text(
                                                          filiere.length
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: AppColors
                                                                .textColor,
                                                            fontSize: 25.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      )),
                                  SizedBox(
                                    width:
                                        constraints.maxWidth > 800 ? 320 : 160,
                                    height: 200,
                                    child: FutureBuilder(
                                      future: get_Data().getCourseData(context),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: LoadingAnimationWidget
                                                .hexagonDots(
                                                    color: AppColors
                                                        .secondaryColor,
                                                    size: 50),
                                          );
                                        } else {
                                          if (snapshot.hasError) {
                                            return errorWidget(
                                                error:
                                                    snapshot.error.toString());
                                            // return const Column(
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   children: [
                                            //     Icon(
                                            //       Icons.error_outline_outlined,
                                            //       color: Colors.red,
                                            //       size: 50,
                                            //     ),
                                            //     Text(
                                            //       'Oups... quelque chose s\'est mal passé',
                                            //     ),
                                            //   ],
                                            // );
                                            // Center(
                                            //   child: Text(
                                            //       'Erreur lors de la récupération des cours actives: ${snapshot.error}'),
                                            // );
                                          } else {
                                            List<dynamic> cours = snapshot.data;
                                            return Card(
                                              color: Colors.white,
                                              elevation: 8.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .settings_applications_outlined,
                                                        color:
                                                            AppColors.courColor,
                                                        size: 70.0,
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      const Text(
                                                        "Cours",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize:
                                                              FontSize.xxLarge,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10.0),
                                                      Text(
                                                        cours.length.toString(),
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 25.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: constraints.maxWidth > 800 ? 640 : 320,
                                height: 105,
                                child: FutureBuilder(
                                  future: get_Data()
                                      .getUnsolvedQueriesData(context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                                color: AppColors.secondaryColor,
                                                size: 50),
                                      );
                                    } else {
                                      if (snapshot.hasError) {
                                        return errorWidget(
                                            error: snapshot.error.toString());
                                        // return const Column(
                                        //   mainAxisSize: MainAxisSize.min,
                                        //   children: [
                                        //     Icon(
                                        //       Icons.error_outline_outlined,
                                        //       color: Colors.red,
                                        //       size: 50,
                                        //     ),
                                        //     Text(
                                        //       'Oups... quelque chose s\'est mal passé',
                                        //     ),
                                        //   ],
                                        // );
                                      } else {
                                        List<dynamic> queries = snapshot.data;
                                        return Card(
                                          color: Colors.white,
                                          elevation: 8.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.query_stats,
                                                        color: AppColors
                                                            .filiereColor,
                                                        size: 50.0,
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      const Text(
                                                        "Requêtes",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize:
                                                              FontSize.xxLarge,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 100.0,
                                                      ),
                                                      Text(
                                                        queries.length
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textColor,
                                                          fontSize: 25.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    "En attente de traitement",
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .accentColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
