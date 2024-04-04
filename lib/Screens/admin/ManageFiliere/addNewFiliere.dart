// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class addNewFilierePage extends StatefulWidget {
  const addNewFilierePage({super.key});

  @override
  _addNewFilierePageState createState() => _addNewFilierePageState();
}

class _addNewFilierePageState extends State<addNewFilierePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  List<String> niveauxDisponibles = [
    'Licence 1',
    'Licence 2',
    'Licence 3',
    'Master 1',
    'Master 2',
    'Doctorat 1',
    'Doctorat 2',
  ];
  List<String> niveauxSelectionnes = [];

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
  void dispose() {
    _nomController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Ajouter une nouvelle filière',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.medium,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Création de filière",
                  style: GoogleFonts.poppins(
                      color: AppColors.textColor,
                      fontSize: FontSize.xxLarge,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    "Entrez les informations de la filière ",
                    style: GoogleFonts.poppins(
                        color: AppColors.secondaryColor,
                        fontSize: FontSize.medium,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 70),
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Filière
                        TextFormField(
                            controller: _nomController,
                            validator: (value) {
                              if (_nomController.text.isEmpty) {
                                return "Ce champ est obligatoire";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            decoration: InputDecoration(
                              labelText:
                                  'Nom de la filière (Génie Logiciel par exemple)',
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
                                    color: Color(0xff9DD1F1), width: 3.0),
                              ),
                            )),
                        const SizedBox(
                          height: 16,
                        ),
                        //champ identifiant
                        TextFormField(
                            controller: _idController,
                            validator: (value) {
                              if (_idController.text.isEmpty) {
                                return "Ce champ est obligatoire";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            decoration: InputDecoration(
                              labelText:
                                  'Identifiant de la filière (GL par exemple)',
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
                                    color: Color(0xff9DD1F1), width: 3.0),
                              ),
                            )),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'Choisir les niveaux',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...niveauxDisponibles.map((niveau) {
                              final isSelected =
                                  niveauxSelectionnes.contains(niveau);
                              return FilterChip(
                                label: Text(niveau),
                                selected: isSelected,
                                onSelected: (selected) {
                                  toggleNiveau(niveau);
                                },
                              );
                            }).toList(),
                            // Tag pour entrer une nouvelle valeur
                            FilterChip(
                              label: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Nouveau niveau',
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    niveauxDisponibles.add(value);
                                  });
                                },
                              ),
                              selected: false,
                              onSelected: (selected) {},
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 50,
                        ),
                        GFButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (niveauxSelectionnes.isNotEmpty) {
                                await set_Data().ajouterFiliere(
                                    _nomController.text,
                                    _idController.text,
                                    niveauxSelectionnes.toSet().toList(),
                                    context);
                              } else {
                                GFToast.showToast(
                                    "Sélectionner au moins un niveau", context,
                                    backgroundColor: Colors.white,
                                    textStyle:
                                        const TextStyle(color: Colors.red),
                                    toastDuration: 6);
                              }
                            }
                          },
                          text: "Ajouter la filière",
                          textStyle: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: GFButtonShape.pills,
                          fullWidthButton: true,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ));
  }
}
