// ignore_for_file: camel_case_types, library_private_types_in_public_api, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageFiliere/manageFiliere.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class addNewFilierePage extends StatefulWidget {
  final Function() callback;
  const addNewFilierePage({super.key, required this.callback});

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
    var currentPage = Provider.of<PageModelAdmin>(context);
    bool isSmallScreen = MediaQuery.of(context).size.shortestSide < 600;
    Form filiereForm = Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
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
                        style: GoogleFonts.poppins(color: AppColors.textColor),
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
                                color: AppColors.secondaryColor, width: 3.0),
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
                        style: GoogleFonts.poppins(color: AppColors.textColor),
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
                                color: AppColors.secondaryColor, width: 3.0),
                          ),
                        )),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'Choisir les niveaux',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      runSpacing: 5,
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
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // Tag pour entrer une nouvelle valeur
                    FilterChip(
                      label: TextField(
                        decoration: const InputDecoration(
                          border: null,
                          hintText: 'Nouveau niveau',
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              niveauxDisponibles.add(value);
                            });
                          }
                        },
                      ),
                      selected: false,
                      onSelected: (selected) {},
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    GFButton(
                      color: AppColors.secondaryColor,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (niveauxSelectionnes.isNotEmpty) {
                            await set_Data().ajouterFiliere(
                                _nomController.text,
                                _idController.text,
                                niveauxSelectionnes.toSet().toList(),
                                context);
                            widget.callback();
                          } else {
                            Helper().ErrorMessage(context,
                                content: "Sélectionnez au moins un niveau");
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
                ))
          ],
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
                              Text("Renseignez les informations de la filière"),
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
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      height: 10,
                    ),
                    const SizedBox(
                      height: 200,
                      child: Image(image: AssetImage("assets/coursImage.jpg")),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Entrez les informations de la filière ",
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
            ),
          );
    // );
  }
}
