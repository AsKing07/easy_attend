// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentFromExcel extends StatefulWidget {
  const AddStudentFromExcel({super.key});

  @override
  State<AddStudentFromExcel> createState() => _AddStudentFromExcelState();
}

class _AddStudentFromExcelState extends State<AddStudentFromExcel> {
  Future<void> selectFile(BuildContext context) async {
    final fileInput = html.FileUploadInputElement();
    fileInput.accept =
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    fileInput.click(); // Simulate a click event to open the file picker dialog

    fileInput.onChange.listen((event) {
      final file = fileInput.files!.first;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) async {
        final result = reader.result;
        if (result is Uint8List) {
          final file = html.Blob([result]);
          final url = html.Url.createObjectUrl(file);

          await auth_methods_admin().addMultipleStudentFromWeb(file, context);

          // Clean up the URL object after use
          html.Url.revokeObjectUrl(url);
        }
      });

      reader.readAsArrayBuffer(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Ajouter plusieurs étudiants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: !screenSize().isWeb()
          ?
          //Mobile App
          SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Création de plusieurs étudiants",
                      style: GoogleFonts.poppins(
                          color: AppColors.textColor,
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        "Suivez attentivement les instructions",
                        style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Instructions",
                      style: TextStyle(
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Le fichier authorisé est un fichier excel d\'extension xlsx',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      "2. Votre fichier excel doit avoir les en-tête suivantes:  'Matricule','Nom','Prenom','Email','Password','Phone','Filiere','Niveau' ",
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '3. Respectez exactement l\'en-tête des colonnes: la casse est importante',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '3. Les noms des filières doivent être écrit en entier (Exemple: GENIE LOGICIEL)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '4. Les noms des niveaux doivent être écrit en entier (Exemple: LICENCE 1)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '5. Un étudiant ayant une filière non créée dans l\'application sera ignoré ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '6.Un étudiant ayant un même matricule ou le même email qu\'un autre étudiant déjà inscrit sera ignoré  ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '6.L\'étudiant pourra plus tard modifier son mot de pass ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    GFButton(
                      onPressed: () async {
                        File? studentsFile;

                        final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xlsx'],
                            allowMultiple: false);
                        if (result != null) {
                          setState(() {
                            studentsFile = File(result.files.single.path!);
                          });
                          await auth_methods_admin()
                              .addMultipleStudent(studentsFile!.path, context);
                        }
                      },
                      text: "Sélectionner le fichier",
                      textStyle: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.large),
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                    )
                  ],
                ),
              ),
            )
          :
          //WebView
          Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Création de plusieurs étudiants",
                      style: GoogleFonts.poppins(
                          color: AppColors.textColor,
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        "Suivez attentivement les instructions",
                        style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Instructions",
                      style: TextStyle(
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Le fichier authorisé est un fichier excel d\'extension xlsx',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      "2. Votre fichier excel doit avoir les en-tête suivantes:  'Matricule','Nom','Prenom','Email','Password','Phone','Filiere','Niveau' ",
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '3. Respectez exactement l\'en-tête des colonnes: la casse est importante',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '3. Les noms des filières doivent être écrit en entier (Exemple: GENIE LOGICIEL)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '4. Les noms des niveaux doivent être écrit en entier (Exemple: LICENCE 1)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '5. Un étudiant ayant une filière non créée dans l\'application sera ignoré ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '6.Un étudiant ayant un même matricule ou le même email qu\'un autre étudiant déjà inscrit sera ignoré  ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      '6.L\'étudiant pourra plus tard modifier son mot de pass ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    GFButton(
                      onPressed: () => selectFile(context),
                      text: "Sélectionner le fichier",
                      textStyle: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.large,
                      ),
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
