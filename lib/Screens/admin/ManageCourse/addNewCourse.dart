// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Cours.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Models/Professeur.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewCoursePage extends StatefulWidget {
  final Function() callback;

  const AddNewCoursePage({super.key, required this.callback});

  @override
  State<AddNewCoursePage> createState() => _AddNewCoursePageState();
}

class _AddNewCoursePageState extends State<AddNewCoursePage> {
  final _formKey = GlobalKey<FormState>();

  List<Filiere> Allfilieres = [];
  List<Prof> AllProfs = [];
  Filiere? _selectedFiliere;
  Prof? _selectedProf;
  var _selectedNiveau;
  final _nomCoursController = TextEditingController();
  final _idCoursController = TextEditingController();

  Future<void> loadAllActifFilieres() async {
    List<dynamic> docsFiliere = await get_Data().getActifFiliereData(context);
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      Filiere filiere = Filiere(
        idDoc: doc['idFiliere'].toString(),
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["sigleFiliere"],
        statut: doc["statut"] == 1,
        niveaux: doc['niveaux'].split(','),
      );

      fil.add(filiere);
    }

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  Future<void> loadAllActifProfData() async {
    List<dynamic> docsProfs = await get_Data().getActifTeacherData(context);
    List<Prof> profs = [];

    for (var doc in docsProfs) {
      Prof prof = Prof(
          idDoc: doc['uid'],
          nom: doc['nom'],
          prenom: doc['prenom'],
          email: doc['email'],
          phone: doc['phone'],
          statut: doc['statut'] == 1);

      profs.add(prof);
    }

    setState(() {
      AllProfs.addAll(profs);
    });
  }

  @override
  void initState() {
    loadAllActifFilieres();
    loadAllActifProfData();
    super.initState();
  }

  @override
  void dispose() {
    _nomCoursController.dispose();
    _idCoursController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        //   appBar: AppBar(
        //     backgroundColor: AppColors.secondaryColor,
        //     foregroundColor: Colors.white,
        //     title: const Text(
        //       'Ajouter un nouveau cours',
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         fontSize: FontSize.medium,
        //       ),
        //     ),
        //   ),
        //   body:
        !screenSize().isLargeScreen(context)
            ?
            //MobileApp View
            SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Création de Cours",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Entrez les informations du cours ",
                          style: GoogleFonts.poppins(
                              color: AppColors.secondaryColor,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Dropdown Filieres
                            DropdownButtonFormField<Filiere>(
                              value: _selectedFiliere,
                              elevation: 18,
                              onChanged: (Filiere? value) {
                                setState(() {
                                  _selectedFiliere = value!;
                                });
                              },
                              items: Allfilieres.map<DropdownMenuItem<Filiere>>(
                                  (Filiere value) {
                                return DropdownMenuItem<Filiere>(
                                  value: value,
                                  child: Text(value.nomFiliere),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Choisissez la filière',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            //Dropdown Niveaux
                            _selectedFiliere != null
                                ? DropdownButtonFormField<String>(
                                    value: _selectedNiveau,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedNiveau = value!;
                                      });
                                    },
                                    items: _selectedFiliere!.niveaux
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Choisissez le niveau',
                                      contentPadding: const EdgeInsets.all(10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: AppColors.secondaryColor,
                                          width: 3.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: AppColors.secondaryColor,
                                            width: 3.0),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            const SizedBox(
                              height: 16,
                            ),

                            //DropdownProfs
                            _selectedNiveau != null && _selectedFiliere != null
                                ? DropdownButtonFormField<Prof>(
                                    value: _selectedProf,
                                    elevation: 18,
                                    onChanged: (Prof? value) {
                                      setState(() {
                                        _selectedProf = value!;
                                      });
                                    },
                                    items: AllProfs.map<DropdownMenuItem<Prof>>(
                                        (Prof value) {
                                      return DropdownMenuItem<Prof>(
                                        value: value,
                                        child: Text(
                                            '${value.nom} ${value.prenom}'),
                                      );
                                    }).toList(),
                                    decoration: const InputDecoration(
                                      labelText: 'Choisissez le professeur',
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : const SizedBox(),

                            const SizedBox(
                              height: 20,
                            ),

                            TextFormField(
                                controller: _nomCoursController,
                                validator: (value) {
                                  if (_nomCoursController.text.isEmpty) {
                                    return "Ce champ est obligatoire";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor),
                                decoration: InputDecoration(
                                  labelText:
                                      'Nom du cours (Par exemple "Base de données Avancées")',
                                  prefixIcon: const Icon(Icons.school),
                                  contentPadding:
                                      const EdgeInsets.only(top: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 3.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 3.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: AppColors.secondaryColor,
                                        width: 3.0),
                                  ),
                                )),

                            const SizedBox(
                              height: 20,
                            ),

                            TextFormField(
                                controller: _idCoursController,
                                validator: (value) {
                                  if (_idCoursController.text.isEmpty) {
                                    return "Ce champ est obligatoire";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor),
                                decoration: InputDecoration(
                                  labelText:
                                      'Identifiant/Sigle du cours (Par exemple "BDA")',
                                  prefixIcon: const Icon(Icons.school),
                                  contentPadding:
                                      const EdgeInsets.only(top: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 3.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 3.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: AppColors.secondaryColor,
                                        width: 3.0),
                                  ),
                                )),
                            const SizedBox(
                              height: 50,
                            ),
                            GFButton(
                              color: AppColors.secondaryColor,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedFiliere == null ||
                                      _selectedProf == null ||
                                      _selectedNiveau == null) {
                                    GFToast.showToast(
                                        "Tous les champs sont requis", context,
                                        backgroundColor: Colors.white,
                                        textStyle:
                                            const TextStyle(color: Colors.red),
                                        toastDuration: 6);
                                  } else {
                                    // Créer le cours
                                    final Cours cours = Cours(
                                        idCours: _idCoursController.text,
                                        nomCours: _nomCoursController.text,
                                        filiereId: _selectedFiliere!.idDoc,
                                        niveau: _selectedNiveau,
                                        professeurId: _selectedProf!.idDoc);

                                    await set_Data()
                                        .ajouterCours(cours, context);
                                    widget.callback();
                                  }
                                }
                              },
                              text: "Créer Cours",
                              textStyle: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontSize: FontSize.large,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: GFButtonShape.pills,
                              fullWidthButton: true,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            //Large screnn
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Création de Cours",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Entrez les informations du cours ",
                          style: GoogleFonts.poppins(
                              color: AppColors.secondaryColor,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                          key: _formKey,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 400), // Définir la largeur maximale
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Dropdown Filieres
                                DropdownButtonFormField<Filiere>(
                                  value: _selectedFiliere,
                                  elevation: 18,
                                  onChanged: (Filiere? value) {
                                    setState(() {
                                      _selectedFiliere = value!;
                                    });
                                  },
                                  items: Allfilieres.map<
                                          DropdownMenuItem<Filiere>>(
                                      (Filiere value) {
                                    return DropdownMenuItem<Filiere>(
                                      value: value,
                                      child: Text(value.nomFiliere),
                                    );
                                  }).toList(),
                                  decoration: const InputDecoration(
                                    labelText: 'Choisissez la filière',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),

                                //Dropdown Niveaux
                                _selectedFiliere != null
                                    ? DropdownButton<String>(
                                        value: _selectedNiveau,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedNiveau = value!;
                                          });
                                        },
                                        items: _selectedFiliere!.niveaux
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        hint:
                                            const Text('Choisissez le niveau'),
                                      )
                                    : const SizedBox(),

                                const SizedBox(
                                  height: 16,
                                ),

                                //DropdownProfs
                                _selectedNiveau != null &&
                                        _selectedFiliere != null
                                    ? DropdownButtonFormField<Prof>(
                                        value: _selectedProf,
                                        elevation: 18,
                                        onChanged: (Prof? value) {
                                          setState(() {
                                            _selectedProf = value!;
                                          });
                                        },
                                        items: AllProfs.map<
                                                DropdownMenuItem<Prof>>(
                                            (Prof value) {
                                          return DropdownMenuItem<Prof>(
                                            value: value,
                                            child: Text(
                                                '${value.nom} ${value.prenom}'),
                                          );
                                        }).toList(),
                                        decoration: const InputDecoration(
                                          labelText: 'Choisissez le professeur',
                                          border: OutlineInputBorder(),
                                        ),
                                      )
                                    : const SizedBox(),

                                const SizedBox(
                                  height: 40,
                                ),

                                TextFormField(
                                    controller: _nomCoursController,
                                    validator: (value) {
                                      if (_nomCoursController.text.isEmpty) {
                                        return "Ce champ est obligatoire";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    decoration: InputDecoration(
                                      labelText:
                                          'Nom du cours (Par exemple "Base de données Avancées")',
                                      prefixIcon: const Icon(Icons.school),
                                      contentPadding:
                                          const EdgeInsets.only(top: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 3.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 3.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: AppColors.secondaryColor,
                                            width: 3.0),
                                      ),
                                    )),

                                const SizedBox(
                                  height: 20,
                                ),

                                TextFormField(
                                    controller: _idCoursController,
                                    validator: (value) {
                                      if (_idCoursController.text.isEmpty) {
                                        return "Ce champ est obligatoire";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    decoration: InputDecoration(
                                      labelText:
                                          'Identifiant/Sigle du cours (Par exemple "BDA")',
                                      prefixIcon: const Icon(Icons.school),
                                      contentPadding:
                                          const EdgeInsets.only(top: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Colors.grey,
                                          width: 3.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 3.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: AppColors.secondaryColor,
                                            width: 3.0),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 50,
                                ),
                                GFButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (_selectedFiliere == null ||
                                          _selectedProf == null ||
                                          _selectedNiveau == null) {
                                        GFToast.showToast(
                                            "Tous les champs sont requis",
                                            context,
                                            backgroundColor: Colors.white,
                                            textStyle: const TextStyle(
                                                color: Colors.red),
                                            toastDuration: 6);
                                      } else {
                                        // Créer le cours
                                        final Cours cours = Cours(
                                            idCours: _idCoursController.text,
                                            nomCours: _nomCoursController.text,
                                            filiereId: _selectedFiliere!.idDoc,
                                            niveau: _selectedNiveau,
                                            professeurId: _selectedProf!.idDoc);

                                        await set_Data()
                                            .ajouterCours(cours, context);
                                        widget.callback();
                                      }
                                    }
                                  },
                                  text: "Créer Cours",
                                  textStyle: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontSize: FontSize.large,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: GFButtonShape.pills,
                                  fullWidthButton: true,
                                ),
                              ],
                            ),
                          ))
                    ],
                  ),
                ),
                // ),
              );
  }
}
