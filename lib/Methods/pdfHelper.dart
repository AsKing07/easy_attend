// ignore_for_file: use_build_context_synchronously, deprecated_member_use, file_names, unused_local_variable,

import 'dart:convert';

import 'package:universal_html/html.dart' as html;

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

class PDFHelper {
  // pdf general
  Future<Uint8List> buildGeneralPdf(
      seanceData, course, BuildContext context) async {
    final pw.Document doc = pw.Document();
    final filiere =
        await get_Data().getFiliereById(course['idFiliere'], context);

    final List<String> absents = [];
    final List<String> presents = [];
    final List<String> allEtudiants = [];

    // Récupérer les noms des étudiants absents et présents
    final Map<String, dynamic> presenceEtudiant =
        jsonDecode(seanceData['presenceEtudiant']);

    await Future.forEach(presenceEtudiant.entries, (entry) async {
      final etudiantId = entry.key;
      final present = entry.value;

      // final etudiantSnapshot = await FirebaseFirestore.instance
      //     .collection('etudiant')
      //     .doc(etudiantId)
      //     .get();
      final etudiantSnapshot =
          await get_Data().getStudentById(etudiantId, context);

      final nom = etudiantSnapshot['nom'];
      final prenom = etudiantSnapshot['prenom'];
      allEtudiants.add('$nom $prenom');

      if (present == false) {
        absents.add('$nom $prenom');
      } else {
        presents.add('$nom $prenom');
      }
    });

    // Load the image from assets
    final Uint8List image =
        (await rootBundle.load('assets/ifri.jpg')).buffer.asUint8List();
    // Ajouter la page PDF
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section with Logo and Title
              pw.Row(
                children: [
                  pw.Image(pw.MemoryImage(image), width: 100, height: 100),
                  pw.SizedBox(width: 20),
                  pw.Text('Rapport de Présence',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Attendance Information
              pw.Text('Cours: ${course['nomCours']}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Classe: ${filiere['nomFiliere']}  ${course['niveau']}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text(
                  'Date de la séance: ${DateFormat('EEEE, d MMMM yyyy, hh:mm', 'fr').format(DateTime.parse(seanceData['dateSeance']).toLocal())}',
                  style: const pw.TextStyle(fontSize: 16)),

              pw.SizedBox(height: 20),

// Seance Information Table
              pw.Table.fromTextArray(
                context: context,
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                  color: PdfColors.grey300,
                ),
                headerHeight: 25,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                },
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                data: [
                  ['Cours', 'Total', 'Presents', 'Absents', 'Pourcentenge'],
                  [
                    course['nomCours'],
                    allEtudiants.length.toString(),
                    presents.length.toString(),
                    absents.length.toString(),
                    '${(presents.length / allEtudiants.length * 100).toStringAsFixed(2)} %',
                  ]
                ],
              ),

              pw.SizedBox(height: 20),

              // Table with Absent and Present Students
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.IntrinsicColumnWidth(),
                  1: const pw.IntrinsicColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Etudiants absents',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Etudiants présents',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children:
                          absents.map((etudiant) => pw.Text(etudiant)).toList(),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: presents
                          .map((etudiant) => pw.Text(etudiant))
                          .toList(),
                    ),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Construire et renvoyer les données finales du fichier PDF
    return await doc.save();
  }

  Future<Uint8List> buildStudentPdf(course, String studentName,
      String studentId, BuildContext context) async {
    final pw.Document doc = pw.Document();
    final filiere =
        await get_Data().getFiliereById(course['idFiliere'], context);

    List<DataRow> rows = [];
    int nombreDePresences = 0;
    int nombreTotalSeances = 0;

    // QuerySnapshot seancesSnapshot = await FirebaseFirestore.instance
    //     .collection('seance')
    //     .where('idCours', isEqualTo: course.id)
    //     .orderBy('dateSeance', descending: true)
    //     .get();
    final seancesSnapshot = await get_Data()
        .getSeanceOfOneCourse(course['idCours'].toString(), context);

    nombreTotalSeances = seancesSnapshot.length;

    for (var seance in seancesSnapshot) {
      Map<String, dynamic> data = seance;
      String date = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'fr')
          .format(DateTime.parse(data['dateSeance']).toLocal());
      Map<String, dynamic> presenceEtudiant =
          jsonDecode(data['presenceEtudiant']);
      bool statut = presenceEtudiant[studentId] ?? false;

      if (statut) {
        nombreDePresences++;
      }

      rows.add(DataRow(cells: [
        DataCell(Text(date)),
        statut
            ? const DataCell(Text(
                'Présent(e)',
                style: TextStyle(color: AppColors.greenColor),
              ))
            : const DataCell(Text(
                'Absent(e)',
                style: TextStyle(color: AppColors.redColor),
              )),
      ]));
    }

    // Load the image from assets
    final Uint8List image =
        (await rootBundle.load('assets/ifri.jpg')).buffer.asUint8List();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Image(pw.MemoryImage(image), width: 100, height: 100),
                  pw.SizedBox(width: 20),
                  pw.Text('Rapport de Présence',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Concerné(e): $studentName',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Cours: ${course['nomCours']}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Classe: ${filiere['nomFiliere']}  ${course['niveau']}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Nombre total de séances: $nombreTotalSeances',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Nombre de présences: $nombreDePresences',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                border: null,
                headerAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headerHeight: 25,
                cellHeight: 25,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
                data: [
                  ['Date de la séance', 'Statut'],
                  for (var row in rows)
                    [
                      pw.Text(
                        (row.cells[0].child as Text).data ?? '',
                      ),
                      pw.Text((row.cells[1].child as Text).data ?? '',
                          style:
                              (row.cells[1].child as Text).data == "Présent(e)"
                                  ? const pw.TextStyle(color: PdfColors.green)
                                  : const pw.TextStyle(color: PdfColors.red)),
                    ],
                ],
              ),
            ],
          );
        },
      ),
    );

    return await doc.save();
  }

  Future<void> savePdf(
      Uint8List pdfBytes, String uniqueName, BuildContext context) async {
    String fileName = formatFileName(uniqueName);

    try {
      if (kIsWeb) {
        // Générer un lien de téléchargement
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Ouvrir le PDF dans un nouvel onglet du navigateur
        html.window.open(url, '_blank');

        // Créer un lien de téléchargement dans le navigateur
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();

        // Libérer l'URL de l'objet blob
        html.Url.revokeObjectUrl(url);

        // Afficher une notification à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF téléchargé avec succès'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (io.Platform.isAndroid) {
        final granted = await requestStoragePermissions();

        if (granted) {
          // Récupère la liste des répertoires de stockage externes
          io.Directory generalDownloadDir = io.Directory(
              '/storage/emulated/0/Download'); // THIS WORKS for android only !!!!!!

          final String path = '${generalDownloadDir.path}/$fileName';

          // Save the Pdf file
          final io.File file = io.File(path);
          await file.writeAsBytes(pdfBytes);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PDF enregistré à: $path'),
            duration: const Duration(seconds: 10),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Autorisation d\'enregistrement, autoriser à partir des paramètres'),
            duration: Duration(seconds: 10),
          ));
        }
      } else {
        final granted = await requestStoragePermissions();

        // IOS
        if (granted) {
          // Récupère le chemin du répertoire des documents d'application pour iOS (peut nécessiter des fonctionnalités ultérieures pour
// être ajouté pour enregistrer directement dans les fichiers)
          final directories = await getApplicationDocumentsDirectory();
          final path = '${directories.path}/$fileName';

          // Save the Pdf file
          final io.File file = io.File(path);
          await file.writeAsBytes(pdfBytes);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PDF enregistré à: $path'),
            duration: const Duration(seconds: 10),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Autorisation d\'écriture refusée, autoriser à partir des paramètres'),
            duration: Duration(seconds: 10),
          ));
        }
      }
    } catch (e) {
      Helper().ErrorMessage(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 100),
        ),
      );

      throw Exception(e);
    }
  }

//pour l'étudiant, ce sera studentName pour enregistrer un fichier de manière unique, tandis que pour l'administrateur et l'enseignant,
// la date d'une session sera sélectionnée

  String formatFileName(String uniqueName) {
    // effectue une manipulation de chaîne pour générer un nom de fichier valide
    uniqueName = uniqueName.replaceAll(' ', '-');
    uniqueName = uniqueName.replaceAll(':', '-');
    String fileName = '$uniqueName-rapportPresence.pdf';
    return fileName;
  }

  static Future<bool> requestStoragePermissions() async {
    await Permission.storage.request();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status == PermissionStatus.granted;
  }
}
