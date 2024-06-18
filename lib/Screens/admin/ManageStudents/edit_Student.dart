// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, file_names

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';

class EditStudentPage extends StatefulWidget {
  final String studentId;
  final void Function() callback;

  const EditStudentPage(
      {super.key, required this.studentId, required this.callback});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();

  var _selectedNiveau;
  Filiere? _selectedFiliere;

  List<Filiere> Allfilieres = [];

  void loadStudentData() async {
    Map<String, dynamic> etudiant =
        await get_Data().getStudentById(widget.studentId, context);

    if (etudiant.isNotEmpty) {
      //final data = etudiant.data() as Map<String, dynamic>;
      _nomController.text = etudiant['nom'];
      _prenomController.text = etudiant['prenom'];
      _phoneController.text = etudiant['phone'];
      _matriculeController.text = etudiant['matricule'];
    }
  }

  Future<void> loadAllActifFilieres() async {
    List<dynamic> docsFiliere = await get_Data().getActifFiliereData(context);
    List<Filiere> fil = [];

    for (var doc in docsFiliere) {
      Filiere filiere = Filiere(
          idDoc: doc['idFiliere'].toString(),
          nomFiliere: doc["nomFiliere"],
          idFiliere: doc["sigleFiliere"],
          statut: doc["statut"] == 1,
          niveaux: doc['niveaux'].split(','));

      fil.add(filiere);
    }

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  @override
  void initState() {
    loadAllActifFilieres();
    loadStudentData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        // appBar: AppBar(
        //   backgroundColor: AppColors.secondaryColor,
        //   foregroundColor: Colors.white,
        //   title: const Text(
        //     'Editer l\'étudiant',
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: FontSize.medium,
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           showDialog(
        //               context: context,
        //               builder: (context) {
        //                 return WarningWidget(
        //                     title: "Information",
        //                     content:
        //                         "Pour toute modification des informations sensibles(Email, Mot de passe), l'utilisateur concerné devra les modifier lui même depuis son compte",
        //                     height: 200);
        //               });
        //         },
        //         icon: const Icon(Icons.info)),
        //   ],
        // ),
        // body:
        !screenSize().isWeb()
            ?
            //MobileApp
            SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Modification d'un étudiant",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Entrez les informations de l'étudiant",
                          style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
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
                            TextFormField(
                              controller: _matriculeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Entrez le matricule",
                                prefixIcon: const Icon(Icons.numbers),
                                contentPadding: const EdgeInsets.only(top: 10),
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
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'S\'il vous plaît entrez le matricule';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _nomController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Entrez le nom",
                                prefixIcon: const Icon(Icons.person_outlined),
                                contentPadding: const EdgeInsets.only(top: 10),
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
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'S\'il vous plaît entrez le nom';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _prenomController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Entrez le prénom",
                                prefixIcon: const Icon(Icons.person_outlined),
                                contentPadding: const EdgeInsets.only(top: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 3.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: AppColors.secondaryColor,
                                      width: 3.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'S\'il vous plaît entrez le prénom';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Entrez le numéro",
                                prefixIcon:
                                    const Icon(Icons.contact_phone_outlined),
                                contentPadding: const EdgeInsets.only(top: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 3.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: AppColors.secondaryColor,
                                      width: 3.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'S\'il vous plâit entrez un numéro valide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            //Dropdown Filieres
                            DropdownButtonFormField<Filiere>(
                              validator: (value) {
                                if (value == null) {
                                  return "Ce champ est obligatoire";
                                } else {
                                  return null;
                                }
                              },
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
                                  labelText: 'Choisissez la filière'),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            //Dropdown Niveaux
                            DropdownButtonFormField<String>(
                              validator: (value) {
                                if (value == null) {
                                  return "Ce champ est obligatoire";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedNiveau = value!;
                                });
                              },
                              items: _selectedFiliere?.niveaux
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              hint: const Text('Choisissez le niveau'),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            GFButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await set_Data().modifierEtudiantByAdmin(
                                      widget.studentId,
                                      _nomController.text,
                                      _prenomController.text,
                                      _phoneController.text,
                                      _selectedFiliere!.nomFiliere,
                                      _selectedFiliere!.idDoc,
                                      _selectedNiveau,
                                      _matriculeController.text,
                                      context);

                                  widget.callback();
                                }
                              },
                              text: "Modifier Etudiant",
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
            :
            //WebView
            Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Modification d'un étudiant",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Entrez les informations de l'étudiant",
                          style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
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
                                TextFormField(
                                  controller: _matriculeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Entrez le matricule",
                                    prefixIcon: const Icon(Icons.numbers),
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
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'S\'il vous plaît entrez le matricule';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: _nomController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: "Entrez le nom",
                                    prefixIcon:
                                        const Icon(Icons.person_outlined),
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
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'S\'il vous plaît entrez le nom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: _prenomController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: "Entrez le prénom",
                                    prefixIcon:
                                        const Icon(Icons.person_outlined),
                                    contentPadding:
                                        const EdgeInsets.only(top: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 3.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: AppColors.secondaryColor,
                                          width: 3.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'S\'il vous plaît entrez le prénom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Entrez le numéro",
                                    prefixIcon: const Icon(
                                        Icons.contact_phone_outlined),
                                    contentPadding:
                                        const EdgeInsets.only(top: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                        width: 3.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: AppColors.secondaryColor,
                                          width: 3.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'S\'il vous plâit entrez un numéro valide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                //Dropdown Filieres
                                DropdownButtonFormField<Filiere>(
                                  validator: (value) {
                                    if (value == null) {
                                      return "Ce champ est obligatoire";
                                    } else {
                                      return null;
                                    }
                                  },
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
                                      labelText: 'Choisissez la filière'),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                //Dropdown Niveaux
                                DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null) {
                                      return "Ce champ est obligatoire";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedNiveau = value!;
                                    });
                                  },
                                  items: _selectedFiliere?.niveaux
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: const Text('Choisissez le niveau'),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                GFButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await set_Data().modifierEtudiantByAdmin(
                                          widget.studentId,
                                          _nomController.text,
                                          _prenomController.text,
                                          _phoneController.text,
                                          _selectedFiliere!.nomFiliere,
                                          _selectedFiliere!.idDoc,
                                          _selectedNiveau,
                                          _matriculeController.text,
                                          context);

                                      widget.callback();
                                    }
                                  },
                                  text: "Modifier Etudiant",
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
              );
    // );
  }
}
