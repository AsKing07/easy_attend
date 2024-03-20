import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/adminMethods/get_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../NativeAdd.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late DocumentSnapshot admin;
  bool dataIsLoaded = false;

  void loadAdmin() async {
    final x = await get_dataAdmin().loadCurrentAdminData();
    setState(() {
      admin = x;
      dataIsLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // Récupérez les données de l'admin à partir de Firebase
    loadAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: !dataIsLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: (Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BannerExample(),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(35, 35, 0, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue ${admin['nom']} ${admin['prenom']}',
                            style: GoogleFonts.poppins(
                                color: AppColors.textColor,
                                fontSize: FontSize.xxLarge,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Consulter les données actuelles',
                            style: GoogleFonts.poppins(
                                color: AppColors.secondaryColor,
                                fontSize: FontSize.medium,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Center(
                        child: Wrap(
                      spacing: 20.0,
                      runSpacing: 20.0,
                      children: [
                        Row(
                          children: [
                            //Données étudiants
                            SizedBox(
                              width: 160,
                              height: 210,
                              child: FutureBuilder(
                                future: get_dataAdmin().getStudentData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Material(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else {
                                    print(snapshot.data.length);
                                    return Card(
                                      color: Colors.white,
                                      elevation: 8.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.people,
                                                color: AppColors.studColor,
                                                size: 80.0,
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              const Text(
                                                "Etudiants",
                                                style: TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: FontSize.xxLarge,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Text(
                                                snapshot.data.length.toString(),
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: 25.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            //données professeur
                            SizedBox(
                                width: 160.0,
                                height: 210.0,
                                child: FutureBuilder(
                                    future: get_dataAdmin().getTeacherData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Material(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else {
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
                                                      size: 80.0,
                                                    ),
                                                    const SizedBox(
                                                      height: 20.0,
                                                    ),
                                                    const Text(
                                                      "Professeurs",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize:
                                                            FontSize.xxLarge,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Text(
                                                      snapshot.data.length
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize: 25.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                      }
                                    })),
                          ],
                        ),
                        Row(
                          children: [
                            //Données filieres
                            SizedBox(
                              width: 160,
                              height: 210,
                              child: FutureBuilder(
                                future: get_dataAdmin().getActifFiliereData(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Material(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else {
                                    print(snapshot.data.length);
                                    return Card(
                                      elevation: 8.0,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.school,
                                                color: AppColors.filiereColor,
                                                size: 80.0,
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              const Text(
                                                "Filières",
                                                style: TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: FontSize.xxLarge,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Text(
                                                snapshot.data.length.toString(),
                                                style: const TextStyle(
                                                  color: AppColors.textColor,
                                                  fontSize: 25.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            //données cours
                            SizedBox(
                                width: 160.0,
                                height: 210.0,
                                child: FutureBuilder(
                                    future: get_dataAdmin().getCourseData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Material(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else {
                                        return Card(
                                            elevation: 8.0,
                                            color: Colors.white,
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
                                                      size: 80.0,
                                                    ),
                                                    const SizedBox(
                                                      height: 20.0,
                                                    ),
                                                    const Text(
                                                      "Cours",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize:
                                                            FontSize.xxLarge,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Text(
                                                      snapshot.data.length
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize: 25.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                      }
                                    })),
                          ],
                        ),
                      ],
                    )),
                  )
                ],
              )),
            ),
    );
  }
}
