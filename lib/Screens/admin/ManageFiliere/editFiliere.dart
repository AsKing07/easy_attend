// ignore_for_file: library_private_types_in_public_api, file_names, prefer_typing_uninitialized_variables

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/manageFiliere.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ModifierFilierePage extends StatefulWidget {
  final filiereId;
  final void Function() callback;

  const ModifierFilierePage(
      {super.key, required this.filiereId, required this.callback});

  @override
  _ModifierFilierePageState createState() => _ModifierFilierePageState();
}

class _ModifierFilierePageState extends State<ModifierFilierePage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  List<String> niveauxSelectionnes = [];
  List<String> niveauxAjoutes = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void loadFiliereData() async {
    Map<String, dynamic> filiere =
        await get_Data().getFiliereById(widget.filiereId, context);

    if (filiere.isNotEmpty) {
      _nomController.text = filiere['nomFiliere'];
      _idController.text = filiere['sigleFiliere'].toString();
      niveauxSelectionnes = filiere['niveaux'].split(',');
      setState(() {
        niveauxAjoutes = niveauxSelectionnes.toList();
      });
    } else {
      // La filière n'existe pas
    }
  }

  @override
  void initState() {
    super.initState();
    // Récupérez les données de la filière à partir de Firebase
    loadFiliereData();
  }

  void toggleNiveau(String niveau) {
    setState(() {
      if (niveauxSelectionnes.contains(niveau)) {
        niveauxSelectionnes.remove(niveau);
      } else {
        niveauxSelectionnes.add(niveau);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentPage = Provider.of<PageModelAdmin>(context);
    bool isSmallScreen = MediaQuery.of(context).size.shortestSide < 600;
    Form filiereForm = Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              //Nom Filière
              TextFormField(
                  controller: _nomController,
                  validator: (value) {
                    if (_nomController.text.isEmpty) {
                      return "Ce champ est obligatoire";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Nom de la filière',
                    prefixIcon: const Icon(Icons.school),
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
                          color: AppColors.secondaryColor, width: 3.0),
                    ),
                  )),
              const SizedBox(
                height: 16,
              ),
              //identifiant
              TextFormField(
                  controller: _idController,
                  validator: (value) {
                    if (_idController.text.isEmpty) {
                      return "Ce champ est obligatoire";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Identifiant de la filière',
                    prefixIcon: const Icon(Icons.school),
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
                          color: AppColors.secondaryColor, width: 3.0),
                    ),
                  )),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Choisir les niveaux',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 5, children: [
                ...niveauxAjoutes.map((niveau) {
                  final isSelected = niveauxSelectionnes.contains(niveau);
                  return FilterChip(
                    label: Text(niveau),
                    selected: isSelected,
                    onSelected: (selected) {
                      toggleNiveau(niveau);
                    },
                  );
                }).toList(),
              ]),
              const SizedBox(
                height: 5,
              ),
              // Tag pour entrer une nouvelle valeur
              FilterChip(
                label: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Nouveau niveau',
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      niveauxAjoutes.add(value);
                    });
                  },
                ),
                selected: false,
                onSelected: (selected) {},
              ),
              const SizedBox(height: 16),
              GFButton(
                color: AppColors.secondaryColor,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (niveauxSelectionnes.isNotEmpty) {
                      set_Data().modifierFiliere(
                          widget.filiereId,
                          _nomController.text,
                          _idController.text,
                          niveauxSelectionnes,
                          context);
                      widget.callback();
                    } else {
                      Helper().ErrorMessage(context,
                          content: "Sélectionnez au moins un niveau");
                    }
                  }
                },
                text: "Modifier la filière",
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
        ));

    return !isSmallScreen
        ? Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Création de filière",
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GFButton(
                      shape: GFButtonShape.pills,
                      text: "Annuler",
                      color: GFColors.DANGER,
                      textStyle: const TextStyle(color: AppColors.white),
                      onPressed: () {
                        currentPage.updatePage(MenuItems(
                            text: 'Filières',
                            icon: Icons.school,
                            tap: const ManageFilierePage()));
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text("Modifiez les informations de la filière"),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 300,
                                child: Image(
                                    image: AssetImage("assets/coursImage.jpg")),
                              )
                            ],
                          )),
                      Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text(
                                  "Remplissez le formulaire",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.secondaryColor,
                                      fontSize: FontSize.xxLarge,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 20),
                              filiereForm
                            ],
                          ))
                    ],
                  )
                ],
              ),
            ),
          )
        : Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Modification de filière",
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GFButton(
                      shape: GFButtonShape.pills,
                      text: "Annuler",
                      color: GFColors.DANGER,
                      textStyle: const TextStyle(color: AppColors.white),
                      onPressed: () {
                        currentPage.updatePage(MenuItems(
                            text: 'Filières',
                            icon: Icons.school,
                            tap: const ManageFilierePage()));
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 200,
                    child: Image(image: AssetImage("assets/coursImage.jpg")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Modifier les informations de la filière ",
                      style: GoogleFonts.poppins(
                          color: AppColors.secondaryColor,
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 15),
                  filiereForm
                ],
              ),
            ),
          );
    // );
  }
}
