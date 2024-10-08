// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:async';
import 'dart:io';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/manageStudent.dart';
import 'package:easy_attend/Screens/etudiant/GiveAttendance/giveQRattendance.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentFromExcel extends StatefulWidget {
  final Function() callback;

  const AddStudentFromExcel({super.key, required this.callback});

  @override
  State<AddStudentFromExcel> createState() => _AddStudentFromExcelState();
}

class _AddStudentFromExcelState extends State<AddStudentFromExcel> {
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
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
          await widget.callback();

          // Clean up the URL object after use
          html.Url.revokeObjectUrl(url);
        }
      });

      reader.readAsArrayBuffer(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    var currentPage = Provider.of<PageModelAdmin>(context);
    return MediaQuery.of(context).size.shortestSide <= 600
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, top: 20),
                    child: Text(
                      'Ajout de plusieurs étudiants',
                      style: GoogleFonts.varelaRound(
                          textStyle: const TextStyle(
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: FontSize.xLarge)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GFButton(
                      fullWidthButton: false,
                      shape: GFButtonShape.pills,
                      text: "Annuler",
                      color: GFColors.DANGER,
                      textStyle: const TextStyle(color: AppColors.white),
                      onPressed: () {
                        currentPage.updatePage(MenuItems(
                            text: 'Etudiants',
                            icon: Icons.person,
                            tap: const ManageStudentPage()));
                      }),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            !isWebMobile
                                ? Center(
                                    child: Lottie.asset(
                                        'assets/uploadAnim.json',
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
                                      image: AssetImage("assets/upload.jpg"),
                                    ),
                                  ),
                            GFButton(
                              color: AppColors.secondaryColor,
                              onPressed: () async {
                                File? studentsFile;

                                final result = await FilePicker.platform
                                    .pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['xlsx'],
                                        allowMultiple: false);
                                if (result != null) {
                                  setState(() {
                                    studentsFile =
                                        File(result.files.single.path!);
                                  });
                                  await auth_methods_admin().addMultipleStudent(
                                      studentsFile!.path, context);
                                  widget.callback();
                                }
                              },
                              text: "Sélectionner le fichier",
                              icon: const Icon(
                                Icons.upload_file,
                                color: AppColors.white,
                              ),
                              textStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.large),
                              shape: GFButtonShape.pills,
                              size: GFSize.LARGE,
                            ),
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                'Comment télécharger le fichier?',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: FontSize.large,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SingleChildScrollView(
                              child: Column(children: [
                                InstructionStep(
                                    number: 1,
                                    text:
                                        "Le fichier autorisé est un fichier excel d'extension xlsx",
                                    icon: Icons.table_view),
                                SizedBox(height: 15),
                                InstructionStep(
                                    number: 2,
                                    text:
                                        " En-têtes obligatoires du fichier:  'Matricule','Nom','Prenom','Email','Password','Phone','Filiere','Niveau'",
                                    icon: Icons.table_rows),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 3,
                                  text:
                                      'Respectez exactement l\'en-tête des colonnes: la casse est importante',
                                  icon: Icons.format_bold,
                                ),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 4,
                                  text:
                                      'Les noms des filières doivent être écrit en entier (Exemple: GENIE LOGICIEL)',
                                  icon: Icons.text_format,
                                ),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 5,
                                  text:
                                      'Les noms des niveaux doivent être écrit en entier (Exemple: LICENCE 1)',
                                  icon: Icons.text_format,
                                ),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 6,
                                  text:
                                      'Un étudiant ayant une filière non créée dans l\'application sera ignoré',
                                  icon: Icons.cancel,
                                ),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 7,
                                  text:
                                      'Un étudiant ayant un même matricule ou le même email qu\'un autre étudiant déjà inscrit sera ignoré',
                                  icon: Icons.cancel,
                                ),
                                SizedBox(height: 15),
                                InstructionStep(
                                  number: 8,
                                  text:
                                      'L\'étudiant pourra plus tard modifier son mot de passe',
                                  icon: Icons.lock,
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ))
        :
        //LargeScreen

        Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Ajout de plusieurs étudiants',
                  style: GoogleFonts.varelaRound(
                      textStyle: const TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.xLarge)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                GFButton(
                    fullWidthButton: false,
                    shape: GFButtonShape.pills,
                    text: "Annuler",
                    color: GFColors.DANGER,
                    textStyle: const TextStyle(color: AppColors.white),
                    onPressed: () {
                      currentPage.updatePage(MenuItems(
                          text: 'Etudiants',
                          icon: Icons.person,
                          tap: const ManageStudentPage()));
                    }),
                Row(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Comment télécharger le fichier?',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: FontSize.large,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const InstructionStep(
                            number: 1,
                            text:
                                "Le fichier autorisé est un fichier excel d'extension xlsx",
                            icon: Icons.table_view),
                        const SizedBox(height: 15),
                        const InstructionStep(
                            number: 2,
                            text:
                                " En-têtes obligatoires du fichier:  'Matricule','Nom','Prenom','Email','Password','Phone','Filiere','Niveau'",
                            icon: Icons.table_rows),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 3,
                          text:
                              'Respectez exactement l\'en-tête des colonnes: la casse est importante',
                          icon: Icons.format_bold,
                        ),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 4,
                          text:
                              'Les noms des filières doivent être écrit en entier (Exemple: GENIE LOGICIEL)',
                          icon: Icons.text_format,
                        ),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 5,
                          text:
                              'Les noms des niveaux doivent être écrit en entier (Exemple: LICENCE 1)',
                          icon: Icons.text_format,
                        ),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 6,
                          text:
                              'Un étudiant ayant une filière non créée dans l\'application sera ignoré',
                          icon: Icons.cancel,
                        ),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 7,
                          text:
                              'Un étudiant ayant un même matricule ou le même email qu\'un autre étudiant déjà inscrit sera ignoré',
                          icon: Icons.cancel,
                        ),
                        const SizedBox(height: 15),
                        const InstructionStep(
                          number: 8,
                          text:
                              'L\'étudiant pourra plus tard modifier son mot de passe',
                          icon: Icons.lock,
                        ),
                      ],
                    ))),
                    Expanded(
                        child: Column(
                      children: [
                        !isWebMobile
                            ? Center(
                                child: Lottie.asset('assets/uploadAnim.json',
                                    height: isSmallScreen
                                        ? screenHeight / 5
                                        : screenHeight / 2,
                                    fit: BoxFit.fill),
                              )
                            : SizedBox(
                                height: isSmallScreen
                                    ? screenHeight / 5
                                    : screenHeight / 2,
                                child: const Image(
                                  image: AssetImage("assets/upload.jpg"),
                                ),
                              ),
                        GFButton(
                          color: AppColors.secondaryColor,
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
                              await auth_methods_admin().addMultipleStudent(
                                  studentsFile!.path, context);
                              widget.callback();
                            }
                          },
                          text: "Sélectionner le fichier",
                          icon: const Icon(
                            Icons.upload_file,
                            color: AppColors.white,
                          ),
                          textStyle: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: FontSize.large),
                          shape: GFButtonShape.pills,
                          size: GFSize.LARGE,
                        )
                      ],
                    ))
                  ],
                )
              ],
            ),
          );
  }
}
