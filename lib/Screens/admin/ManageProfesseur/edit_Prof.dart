// ignore_for_file: file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class EditProfPage extends StatefulWidget {
  final dynamic profId;
  final void Function() callback;

  const EditProfPage({super.key, required this.profId, required this.callback});

  @override
  State<EditProfPage> createState() => _EditProfPageState();
}

class _EditProfPageState extends State<EditProfPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String phoneNumber = "";

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  void _inputPhoneChange(
      String number, PhoneNumber internationlizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNumber = internationlizedPhoneNumber.completeNumber;
    });
  }

  void loadProfData() async {
    Map<String, dynamic> prof =
        await get_Data().getProfById(widget.profId, context);

    if (prof.isNotEmpty) {
      _nomController.text = prof['nom'];
      _prenomController.text = prof['prenom'];
      _phoneController.text = prof['phone'];
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfData();
  }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        // appBar: AppBar(
        //   backgroundColor: AppColors.secondaryColor,
        //   foregroundColor: Colors.white,
        //   title: const Text(
        //     'Editer le professeur',
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
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Modification de professeur",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Modifier les informations du professeur ",
                          style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 70),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                                controller: _nomController,
                                validator: (value) {
                                  if (_nomController.text.isEmpty) {
                                    return "Ce champ est obligatoire";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor),
                                decoration: InputDecoration(
                                  labelText: 'Nom du prof',
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
                              height: 16,
                            ),
                            TextFormField(
                                controller: _prenomController,
                                validator: (value) {
                                  if (_phoneController.text.isEmpty) {
                                    return "Ce champ est obligatoire";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor),
                                decoration: InputDecoration(
                                  labelText: 'Prénom du prof',
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
                              height: 16,
                            ),
                            IntlPhoneField(
                              showDropdownIcon: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              focusNode: FocusNode(),
                              decoration: InputDecoration(
                                labelText: 'Numéro de téléphone',
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
                              languageCode: "fr",
                              onChanged: (number) {
                                _inputPhoneChange(number.number, number,
                                    number.countryISOCode);
                              },
                            ),

                            // TextFormField(
                            //     controller: _phoneController,
                            //     validator: (value) {
                            //       if (_phoneController.text.isEmpty) {
                            //         return "Ce champ est obligatoire";
                            //       }
                            //       return null;
                            //     },
                            //     keyboardType: TextInputType.phone,
                            //     style: GoogleFonts.poppins(
                            //         color: AppColors.textColor),
                            //     decoration: InputDecoration(
                            //       labelText: 'Téléphone',
                            //       prefixIcon: const Icon(Icons.phone),
                            //       contentPadding: const EdgeInsets.only(top: 10),
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //         borderSide: const BorderSide(
                            //           color: Colors.grey,
                            //           width: 3.0,
                            //         ),
                            //       ),
                            //       errorBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //         borderSide: const BorderSide(
                            //           color: Colors.red,
                            //           width: 3.0,
                            //         ),
                            //       ),
                            //       focusedBorder: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //         borderSide: const BorderSide(
                            //             color: AppColors.secondaryColor,
                            //             width: 3.0),
                            //       ),
                            //     )),

                            const SizedBox(
                              height: 16,
                            ),
                            GFButton(
                              color: AppColors.secondaryColor,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await set_Data().modifierProfByAdmin(
                                      widget.profId,
                                      _nomController.text,
                                      _prenomController.text,
                                      phoneNumber,
                                      context);
                                  widget.callback();
                                }
                              },
                              text: 'Modifier le professseur',
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
            //large screen
            Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Modification de professeur",
                        style: GoogleFonts.poppins(
                            color: AppColors.textColor,
                            fontSize: FontSize.xxLarge,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          "Modifier les informations du professeur ",
                          style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 70),
                      Form(
                          key: _formKey,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: 400), // Définir la largeur maximale
                            child: Column(
                              children: [
                                TextFormField(
                                    controller: _nomController,
                                    validator: (value) {
                                      if (_nomController.text.isEmpty) {
                                        return "Ce champ est obligatoire";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    decoration: InputDecoration(
                                      labelText: 'Nom du prof',
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
                                  height: 16,
                                ),
                                TextFormField(
                                    controller: _prenomController,
                                    validator: (value) {
                                      if (_phoneController.text.isEmpty) {
                                        return "Ce champ est obligatoire";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    decoration: InputDecoration(
                                      labelText: 'Prénom du prof',
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
                                  height: 16,
                                ),
                                IntlPhoneField(
                                  showDropdownIcon: false,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  focusNode: FocusNode(),
                                  decoration: InputDecoration(
                                    labelText: 'Numéro de téléphone',
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
                                  languageCode: "fr",
                                  onChanged: (number) {
                                    _inputPhoneChange(number.number, number,
                                        number.countryISOCode);
                                  },
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                GFButton(
                                  color: AppColors.secondaryColor,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await set_Data().modifierProfByAdmin(
                                          widget.profId,
                                          _nomController.text,
                                          _prenomController.text,
                                          phoneNumber,
                                          context);
                                      widget.callback();
                                    }
                                  },
                                  text: 'Modifier le professseur',
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
  }
}
