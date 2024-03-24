// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/adminMethods/connexion_methods_admin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentFromExcel extends StatefulWidget {
  const AddStudentFromExcel({super.key});

  @override
  State<AddStudentFromExcel> createState() => _AddStudentFromExcelState();
}

class _AddStudentFromExcelState extends State<AddStudentFromExcel> {
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
      body: SingleChildScrollView(
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
              ElevatedButton(
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
                      await connexion_methods_admin()
                          .addMultipleStudent(studentsFile!.path, context);
                    }
                  },
                  child: const Text("Sélectionner le fichier"))
            ],
          ),
        ),
      ),
    );
  }
}
