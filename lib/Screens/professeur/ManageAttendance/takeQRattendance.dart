// ignore_for_file: file_names, must_be_immutable, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lottie/lottie.dart';

class TakeQrAttendancePage extends StatefulWidget {
  String seanceId;
  TakeQrAttendancePage({super.key, required this.seanceId});
  @override
  State<TakeQrAttendancePage> createState() => _TakeQrAttendancePageState();
}

class _TakeQrAttendancePageState extends State<TakeQrAttendancePage> {
  late DocumentSnapshot seance;
  bool dataIslLoaded = false;
  bool started = false;

  Future loadSeance() async {
    var x = await get_Data().getSeanceById(widget.seanceId, context);

    setState(() {
      seance = x;
      dataIslLoaded = true;
      started = x['isActive'];
    });
  }

  @override
  void initState() {
    loadSeance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !dataIslLoaded
        ? const SizedBox()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Prise de présence ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.medium,
                ),
              ),
            ),
            body: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  child: Center(
                      child: !started
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, top: 20),
                                  child: Text(
                                    'Instructions pour le scan ',
                                    style: GoogleFonts.varelaRound(
                                        textStyle: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(
                                    height: 15,
                                    thickness: 2,
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 350),
                                  child: Lottie.asset('assets/qrAnim.json'),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '1. Lancez la séance de présence.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  '2.Les étudiants scannent le  code QR',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  '3. Arretez la séance de présence pour empêcher tout nouveau scan',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      started = true;
                                    });

                                    await set_Data().starSeance(seance.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.white,
                                    backgroundColor: AppColors.secondaryColor,
                                  ),
                                  child: const Text(
                                    'Démarrer la séance',
                                    style: TextStyle(
                                        fontSize: FontSize.xMedium,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                    child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 0),
                                    child: QrImageView(
                                      data: seance['seanceCode'],
                                      version: QrVersions.auto,
                                      size: 300.0,
                                    ),
                                  ),
                                )),
                                const SizedBox(
                                  height: 40,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      started = false;
                                    });

                                    await set_Data().stopSeance(seance.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppColors.white,
                                    backgroundColor: AppColors.secondaryColor,
                                  ),
                                  child: const Text(
                                    'Arreter la séance de présence',
                                    style: TextStyle(
                                        fontSize: FontSize.xMedium,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            )),
                )),
          );
  }
}
