// ignore_for_file: use_build_context_synchronously, file_names, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class GiveQrAttendancePage extends StatefulWidget {
  const GiveQrAttendancePage({super.key});

  @override
  State<GiveQrAttendancePage> createState() => _GiveQrAttendancePageState();
}

class _GiveQrAttendancePageState extends State<GiveQrAttendancePage> {
  String studentId = "";

  void scanPass(BuildContext context) async {
    String res = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'Arreter le scan', true, ScanMode.QR);
    final x = await get_Data().getSeanceByCode(res);
    print(x);

    if (x != null) {
      final seanceDoc = x;

      if (seanceDoc['isActive'] == 0) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: AppColors.white,
                scrollable: true,
                title: const Center(
                    child: Text(
                  "Erreur",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 24),
                )),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      scanPass(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenColor,
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                  ),
                ],
                content: Container(
                    child: Column(
                  children: [
                    Lottie.asset('assets/failed.json'),
                    const SizedBox(height: 10),
                    const Text("La séance de présence est actuellement fermée",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
              );
            });
      } else {
        try {
          final bool x = await set_Data().updatePresenceEtudiant(
              seanceDoc['seanceCode'], studentId, true, context);
          if (x == true) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.white,
                    scrollable: true,
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                    title: const Center(
                        child: Text("Présence enregistrée",
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold))),
                    content: Column(
                      children: [
                        Lottie.asset('assets/done.json', repeat: false),
                        const SizedBox(height: 10),
                        const Text("Votre présence a bien été enregistrée",
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                });
          }
        } catch (e) {
          print(e);
        }
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              scrollable: true,
              title: const Center(
                  child: Text(
                "Erreur",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 24),
              )),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    scanPass(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenColor),
                  child: const Text(
                    'Réessayer',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
              ],
              content: Container(
                  child: Column(
                children: [
                  Lottie.asset('assets/failed.json'),
                  const SizedBox(height: 10),
                  const Text("Aucune séance ne correspond à ce code QR",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              )),
            );
          });
    }
  }

  void getStudentId() async {
    DocumentSnapshot x = await get_Data().loadCurrentStudentData();
    setState(() {
      studentId = x.id;
    });
  }

  @override
  void initState() {
    getStudentId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
            child: Text(
              'Instructions pour le scan QR ',
              style: GoogleFonts.varelaRound(
                  textStyle: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Divider(
              color: AppColors.secondaryColor,
              height: 15,
              thickness: 2,
            ),
          ),
          Lottie.asset('assets/qrAnim.json'),
          const SizedBox(height: 10),
          const Text(
            '1. Tenez le téléphone en position verticale.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            '2.Centrez le code QR sur le cadre de la caméra',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            '3.Attendez que le pass soit scanné',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              scanPass(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.secondaryColor,
            ),
            child: const Text(
              'Démarrer le Scan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ))),
    );
  }
}
