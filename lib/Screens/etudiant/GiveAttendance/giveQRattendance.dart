// ignore_for_file: use_build_context_synchronously, file_names, avoid_unnecessary_containers

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../Config/utils.dart';

class GiveQrAttendancePage extends StatefulWidget {
  const GiveQrAttendancePage({super.key});

  @override
  State<GiveQrAttendancePage> createState() => _GiveQrAttendancePageState();
}

class _GiveQrAttendancePageState extends State<GiveQrAttendancePage> {
  static const double campusLatitude = 6.4164971; // latitude du campus
  static const double campusLongitude = 2.3405719; //  longitude du campus
  static const double maxDistance = 30.0; // Distance maximale en mètres
  String? statusMessage;
  String studentId = "";
  dynamic student;
  final bool isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        // La permission est accordée
      } else {
        setState(() {
          statusMessage = 'Permission de localisation refusée';
        });
      }
    }
  }

  Future<void> scanPassWeb() async {
    if (isWebMobile) {
      String scanResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SimpleBarcodeScannerPage()),
      );
      scanPass(context, res: scanResult);
    } else {
      _showErrorToast(
          "Le scan n'est pris en charge que pour les navigateurs Web mobiles.");
    }
  }

  Future<void> scanPass(BuildContext context, {String? res}) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    res ??= await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'Arrêter le scan', true, ScanMode.QR);
    final x = await get_Data().getSeanceByCode(res, context);

    if (x != null) {
      _handleSeance(x, res);
    } else {
      Navigator.pop(context);
      _showErrorDialog(context, "Aucune séance ne correspond à ce code QR");
    }
  }

  Future<void> _handleSeance(dynamic seanceDoc, String? res) async {
    if (seanceDoc['isActive'] == 0) {
      Navigator.pop(context);
      _showErrorDialog(
          context, "La séance de présence est actuellement fermée");
    } else {
      await _checkGeolocation(seanceDoc, res);
    }
  }

  Future<void> _checkGeolocation(dynamic seanceDoc, String? res) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        campusLatitude,
        campusLongitude,
      );

      if (distance <= maxDistance) {
        await _verifyCourse(seanceDoc, res);
      } else {
        Navigator.pop(context);
        _showErrorDialog(context,
            "Vous êtes trop loin du campus pour signer la présence : $distance mètres");
      }
    } catch (e) {
      Navigator.pop(context);
      kReleaseMode
          ? Helper().ErrorMessage(context)
          : _showSnackBar('Une erreur s\'est produite. Erreur:$e');
    }
  }

  Future<void> _verifyCourse(dynamic seanceDoc, String? res) async {
    final cours = await get_Data().getCourseById(seanceDoc['idCours'], context);
    if (cours['idFiliere'] == student['idFiliere']) {
      final bool x = await set_Data().updatePresenceEtudiant(
          seanceDoc['seanceCode'], studentId, true, context);
      if (x == true) {
        Navigator.pop(context);
        _showSuccessDialog(context, "Présence enregistrée",
            "Votre présence a bien été enregistrée");
      }
    } else {
      Navigator.pop(context);
      Helper().ErrorMessage(context,
          content: "Vous n'êtes pas inscrit dans cette filière");
    }
  }

  void getStudentId() async {
    dynamic x = await get_Data().loadCurrentStudentData();
    setState(() {
      studentId = x['uid'];
      student = x;
    });
  }

  @override
  void initState() {
    getStudentId();
    _checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isWebComputer = kIsWeb && !isWebMobile;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    return isWebComputer
        ? Center(
            child: Card(
                color: Colors.orange,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Le scan n'est pris en charge que pour les navigateurs Web mobiles et sur l'app mobile.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.bold),
                    ))),
          )
        : Center(
            child: Container(
                child: SingleChildScrollView(
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
                  child: Text(
                    'Signer votre présence ',
                    style: GoogleFonts.varelaRound(
                        textStyle: const TextStyle(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSize.xLarge)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          !isWebMobile
                              ? Center(
                                  child: Lottie.asset('assets/qrAnim2.json',
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
                                    image: AssetImage("assets/scan.jpg"),
                                  ),
                                ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                textAlign: TextAlign.center,
                                'Le résultat du scan sera affiché sur votre écran une fois le code QR scanné.',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GFButton(
                            color: AppColors.secondaryColor,
                            onPressed: () {
                              screenSize().isWeb()
                                  ? scanPassWeb()
                                  : scanPass(context);
                            },
                            text: 'Scanner QR code',
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            shape: GFButtonShape.pills,
                            size: GFSize.LARGE,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
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
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InstructionStep(
                                  number: 1,
                                  text:
                                      "Assurez-vous d'être à moins de 500 mètres de votre uiversité",
                                  icon: Icons.location_on,
                                ),
                                SizedBox(height: 20),
                                InstructionStep(
                                  number: 2,
                                  text:
                                      'Assurez-vous que votre caméra est propre et fonctionnelle.',
                                  icon: Icons.camera_alt,
                                ),
                                SizedBox(height: 20),
                                InstructionStep(
                                  number: 3,
                                  text:
                                      ' Lancer le scan QR sur votre appareil.',
                                  icon: Icons.qr_code_scanner,
                                ),
                                SizedBox(height: 20),
                                InstructionStep(
                                  number: 4,
                                  text:
                                      'Alignez le code QR dans le cadre de la caméra.',
                                  icon: Icons.center_focus_strong,
                                ),
                                SizedBox(height: 20),
                                InstructionStep(
                                  number: 5,
                                  text:
                                      'Attendez que l\'application reconnaisse et scanne le code.',
                                  icon: Icons.check_circle_outline,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ],
            ))),
          );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: IntrinsicHeight(
          child: Column(
            children: [
              Lottie.asset('assets/failed.json', repeat: true),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              screenSize().isWeb() ? scanPassWeb() : scanPass(context);
            },
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: IntrinsicHeight(
            child: Column(
          children: [
            Lottie.asset('assets/done.json', repeat: true),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        )),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    Helper().ErrorMessage(context, content: message);
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class InstructionStep extends StatelessWidget {
  final int number;
  final String text;
  final IconData icon;

  const InstructionStep(
      {Key? key, required this.number, required this.text, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.teal,
          child: Text(
            number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
