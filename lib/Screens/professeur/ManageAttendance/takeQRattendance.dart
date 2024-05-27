// ignore_for_file: file_names, must_be_immutable, avoid_unnecessary_containers

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lottie/lottie.dart';

class TakeQrAttendancePage extends StatefulWidget {
  final dynamic seance;
  final Function() callback;
  const TakeQrAttendancePage(
      {super.key, required this.seance, required this.callback});
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
    return Scaffold(
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
                    ? Center(
                        child: SingleChildScrollView(
                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Divider(
                              height: 15,
                              thickness: 2,
                            ),
                          ),
                          !isWebMobile
                              ? ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 350),
                                  child: Lottie.asset('assets/qrAnim.json'),
                                )
                              : const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '1. Lancez la séance de présence.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                '2.Les étudiants scannent le  code QR',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
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

                                  await set_Data()
                                      .startSeance(widget.seance['idSeance']);
                                  widget.callback();
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
                        ],
                      )))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                started = false;
                              });

                              await set_Data()
                                  .stopSeance(widget.seance['idSeance']);
                              widget.callback();
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
