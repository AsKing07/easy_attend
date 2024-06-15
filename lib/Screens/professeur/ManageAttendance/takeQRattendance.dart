// ignore_for_file: file_names, must_be_immutable, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Screens/etudiant/GiveAttendance/giveQRattendance.dart';
import 'package:easy_attend/Screens/professeur/ManageAttendance/seeAttendance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lottie/lottie.dart';

class TakeQrAttendancePage extends StatefulWidget {
  final dynamic seance;
  final dynamic course;
  final Function() callback;
  const TakeQrAttendancePage(
      {super.key,
      required this.seance,
      required this.callback,
      required this.course});
  @override
  State<TakeQrAttendancePage> createState() => _TakeQrAttendancePageState();
}

class _TakeQrAttendancePageState extends State<TakeQrAttendancePage> {
  bool started = false;
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  void initState() {
    started = widget.seance["isActive"] == 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Prise de présence de ${widget.course['nomCours']} ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            child: Center(
                child: Container(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 12, right: 12, top: 20),
                        child: Text(
                          'Prenez la présence ${widget.course['nomCours']} ',
                          style: GoogleFonts.varelaRound(
                              textStyle: const TextStyle(
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.xLarge)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              started
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 0),
                                            child: QrImageView(
                                              data: widget.seance['seanceCode'],
                                              version: QrVersions.auto,
                                              size: 300.0,
                                            ),
                                          ),
                                        )),
                                        const SizedBox(
                                          height: 40,
                                        ),
                                        GFButton(
                                          color: AppColors.redColor,
                                          onPressed: () async {
                                            setState(() {
                                              started = false;
                                            });

                                            await set_Data().stopSeance(
                                                widget.seance['idSeance']);
                                            widget.callback();
                                            if (!screenSize()
                                                .isLargeScreen(context)) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeeSeanceAttendanceProf(
                                                              seance:
                                                                  widget.seance,
                                                              course: widget
                                                                  .course)));
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          shape: GFButtonShape.pills,
                                          size: GFSize.LARGE,
                                          text: 'Arreter la séance de présence',
                                        ),
                                      ],
                                    )
                                  : !isWebMobile
                                      ? Center(
                                          child: Lottie.asset(
                                              'assets/qrAnim2.json',
                                              // width: 600,
                                              height: isSmallScreen
                                                  ? screenHeight / 4
                                                  : screenHeight / 1.5,
                                              fit: BoxFit.fill),
                                        )
                                      : SizedBox(
                                          height: isSmallScreen
                                              ? screenHeight / 4
                                              : screenHeight / 1.5,
                                          child: const Image(
                                            image:
                                                AssetImage("assets/scan.jpg"),
                                          ),
                                        ),
                              Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Comment Scanner le Code QR?',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: FontSize.large,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                  child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const InstructionStep(
                                      number: 1,
                                      text:
                                          "Lancer la séance de scan de présence",
                                      icon: Icons.qr_code_scanner,
                                    ),
                                    const SizedBox(height: 20),
                                    const Center(
                                      child: InstructionStep(
                                        number: 2,
                                        text:
                                            'Partagez le code QR avec les étudiants',
                                        icon: Icons.share,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const InstructionStep(
                                      number: 3,
                                      text:
                                          'Les étudiants scannent le code QR depuis leur application.',
                                      icon: Icons.center_focus_strong,
                                    ),
                                    const SizedBox(height: 20),
                                    const InstructionStep(
                                      number: 4,
                                      text:
                                          'Tous les étudiants ont scanné le code.',
                                      icon: Icons.check_circle_outline,
                                    ),
                                    const SizedBox(height: 20),
                                    const InstructionStep(
                                      number: 5,
                                      text:
                                          'Arrêter la séance pour empêcher tout nouveau scan.',
                                      icon: Icons.close,
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.teal,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          'Une fois la séance terminée, vous pourrez consulter la présence sur votre écran.',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!started)
                                      GFButton(
                                        color: AppColors.secondaryColor,
                                        onPressed: () async {
                                          setState(() {
                                            started = true;
                                          });

                                          await set_Data().startSeance(
                                              widget.seance['idSeance']);
                                          widget.callback();
                                        },
                                        text: 'Démarrer la séance',
                                        icon: const Icon(
                                          Icons.qr_code_scanner,
                                          color: Colors.white,
                                        ),
                                        shape: GFButtonShape.pills,
                                        size: GFSize.LARGE,
                                      )
                                  ],
                                ),
                              ))
                            ],
                          )),
                    ]),
              ),
            )),
          )),
    );
  }
}
