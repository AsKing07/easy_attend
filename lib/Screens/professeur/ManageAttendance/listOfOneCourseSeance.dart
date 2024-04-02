import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Seance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeAttendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/takeAttendanceManualy.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/takeQRattendance.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:easy_attend/Widgets/noResultWidget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ListOfOneCourseSeancePage extends StatefulWidget {
  String CourseId;

  ListOfOneCourseSeancePage({required this.CourseId});
  @override
  State<ListOfOneCourseSeancePage> createState() =>
      _ListOfOneCourseSeancePageState();
}

class _ListOfOneCourseSeancePageState extends State<ListOfOneCourseSeancePage> {
  List<Seance> AllSeances = [];
  late DocumentSnapshot course;
  bool dataIsloaded = false;

  Future<void> loadCourseSeance() async {
    course = await get_Data().getCourseById(widget.CourseId, context);

    setState(() {
      dataIsloaded = true;
    });
  }

  @override
  void initState() {
    initializeDateFormatting('fr');
    loadCourseSeance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !dataIsloaded
        ? const SizedBox()
        : Scaffold(
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
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('seance')
                              .where('idCours', isEqualTo: widget.CourseId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs.isEmpty) {
                                return const NoResultWidget();
                              } else {
                                final seances = snapshot.data!.docs;
                                return ListView.builder(
                                    itemCount: seances.length,
                                    itemBuilder: (context, index) {
                                      final seance = seances[index];
                                      final seanceData =
                                          seance.data() as Map<String, dynamic>;
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
                                                  left: 30.0),
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
                                                                    'EEEE, d MMMM yyyy, hh:mm',
                                                                    'fr')
                                                                .format(seanceData[
                                                                        'dateSeance']
                                                                    .toDate())
                                                                .toUpperCase(),
                                                            style: const TextStyle(
                                                                color: AppColors
                                                                    .secondaryColor,
                                                                fontSize:
                                                                    FontSize
                                                                        .medium,
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
                                                            child: seanceData[
                                                                    'isActive']
                                                                ? const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: AppColors
                                                                        .greenColor,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .circle,
                                                                    color: AppColors
                                                                        .redColor),
                                                          )
                                                        ],
                                                      ),
                                                      collapsed: Column(
                                                        children: [
                                                          Text(
                                                            "${course['nomCours']} - ${course['niveau']} ",
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize:
                                                                    FontSize
                                                                        .medium,
                                                                color: AppColors
                                                                    .textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                          !seanceData[
                                                                  'presenceTookOnce']
                                                              ? const Text(
                                                                  "Aucune présence effectuée",
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: AppColors
                                                                          .textColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                )
                                                              : const Text(
                                                                  "Une présence a été effectuée sur cette séance",
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
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
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          !seanceData[
                                                                  'presenceTookOnce']
                                                              ? const Text(
                                                                  "Aucune présence effectuée",
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: AppColors
                                                                          .textColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                )
                                                              : ElevatedButton(
                                                                  style: const ButtonStyle(
                                                                      fixedSize:
                                                                          MaterialStatePropertyAll(Size(
                                                                              280,
                                                                              30))),
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SeeSeanceAttendanceProf(seanceId: seance.id)),
                                                                    );
                                                                  },
                                                                  child: const Text(
                                                                      "Consulter la présence déjà prise")),
                                                          ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  fixedSize:
                                                                      MaterialStatePropertyAll(Size(
                                                                          280,
                                                                          30))),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => TakeManualAttendance(
                                                                          seanceId: seance
                                                                              .id,
                                                                          courseId:
                                                                              widget.CourseId)),
                                                                );
                                                              },
                                                              child: const Text(
                                                                  "PRESENCE MANUELLE")),
                                                          ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  fixedSize:
                                                                      MaterialStatePropertyAll(Size(
                                                                          280,
                                                                          30))),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          TakeQrAttendancePage(
                                                                              seanceId: seance.id)),
                                                                );
                                                              },
                                                              child: const Text(
                                                                "PRESENCE CODE QR",
                                                              )),
                                                          ElevatedButton(
                                                              style: const ButtonStyle(
                                                                  fixedSize:
                                                                      MaterialStatePropertyAll(Size(
                                                                          280,
                                                                          30)),
                                                                  backgroundColor:
                                                                      MaterialStatePropertyAll(
                                                                          AppColors
                                                                              .redColor)),
                                                              onPressed:
                                                                  () async {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          AlertDialog(
                                                                    title:
                                                                        const Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .warning,
                                                                          color:
                                                                              Colors.orange,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          "Supprimer la séance",
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20.0,
                                                                              color: Colors.orange),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                            'Êtes-vous sûr de vouloir supprimer cette séance ?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            'Annuler'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await set_Data().deleteSeance(
                                                                              seance.id,
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Supprimer'),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                "Supprimer la séance",
                                                                style: TextStyle(
                                                                    color: AppColors
                                                                        .white),
                                                              )),
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
                            } else if (snapshot.hasError) {
                              Helper().ErrorMessage(context);
                              return const SizedBox();
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )),
                  ],
                ),
              ),
            ));
  }
}
