// ignore_for_file: use_build_context_synchronously, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dialogs/dialogs/message_dialog.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MakeQuery extends StatefulWidget {
  const MakeQuery({super.key});

  @override
  State<MakeQuery> createState() => _MakeQueryState();
}

class _MakeQueryState extends State<MakeQuery> {
  late DocumentSnapshot etudiant;
  bool dataIsLoaded = false;

  String dropdownValue = 'Selectionnez un type';

  String queryTypeFromDB = "Aucune requete trouvée";
  String querySubjectFromDB = "----";
  String queryFromDB = "Vous n'avez envoyé aucune requête";
  String queryStatusFromDB = "null";

  final TextEditingController _queryController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();

  List<String> type = [
    'Suppression de compte',
    'Demande de permission d\'absence',
    'Justification d\'absence',
    'Autre requête'
  ];

  void loadCurrentStudent() async {
    try {
      final x = await get_Data().loadCurrentStudentData();

      final DocumentSnapshot query = await get_Data().getQueryById(x.id);

      setState(() {
        etudiant = x;
        dataIsLoaded = true;
        querySubjectFromDB = query['sujet'];
        queryTypeFromDB = query['type'];
        queryStatusFromDB = query["statut"];
        queryFromDB = query['details'];
      });
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    loadCurrentStudent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !dataIsLoaded
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.secondaryColor, size: 200),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          "Vous ne pouvez avoir qu'une seule requête en cours de traitement"),
                      const SizedBox(
                        height: 30,
                      ),
                      DecoratedBox(
                        decoration: const ShapeDecoration(
                          color: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            isDense: true,
                            borderRadius: BorderRadius.circular(30),
                            hint: Text(
                              dropdownValue,
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            items: type
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Center(
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                dropdownValue = value.toString();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          filled: true,
                          labelText: "Objet de la requête",
                          hintText: "Objet en quelques mots",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _queryController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: "Requête",
                          filled: true,
                          hintText: "Expliquer votre requête",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (dropdownValue.isEmpty ||
                                _subjectController.text.isEmpty ||
                                _queryController.text.isEmpty) {
                              GFToast.showToast(
                                  "Tous les champs sont requis", context,
                                  textStyle: const TextStyle(
                                    color: AppColors.redColor,
                                  ),
                                  backgroundColor: AppColors.white);
                            } else {
                              DateTime x = DateTime.now();
                              await set_Data().createQuery(
                                  "${etudiant['nom']} ${etudiant['prenom']}",
                                  etudiant.id,
                                  dropdownValue,
                                  _subjectController.text,
                                  _queryController.text,
                                  "2",
                                  x,
                                  context);

                              loadCurrentStudent();
                            }
                          },
                          child: const Text('Soumettre')),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            MessageDialog messageDialog = MessageDialog(
                              dialogBackgroundColor: Colors.white,
                              buttonOkColor: AppColors.greenColor,
                              title: queryTypeFromDB,
                              titleColor: Colors.black,
                              message:
                                  "Objet de la requête: $querySubjectFromDB  \n \n   $queryFromDB \n \n Statut:  ${queryStatusFromDB == "2" ? "En attente de traitement" : queryStatusFromDB == "1" ? "Approuvé" : "Rejeté"}",
                              messageColor: Colors.black,
                              buttonOkText: 'Retour',
                              dialogRadius: 30.0,
                              buttonRadius: 15.0,
                            );
                            messageDialog.show(context,
                                barrierColor: Colors.white);
                          },
                          child: const Text("Voir ma requête en cours"))
                    ],
                  ),
                ),
              ));
  }
}
