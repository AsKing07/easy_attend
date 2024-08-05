// ignore_for_file: file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Models/menuItems.dart';
import 'package:easy_attend/Screens/admin/ManageProfesseur/manageProf.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';

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
    var currentPage = Provider.of<PageModelAdmin>(context);
    bool isSmallScreen = MediaQuery.of(context).size.shortestSide < 600;

    Form editProfForm = Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
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
                  style: GoogleFonts.poppins(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Nom du prof',
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
              TextFormField(
                  controller: _prenomController,
                  validator: (value) {
                    if (_phoneController.text.isEmpty) {
                      return "Ce champ est obligatoire";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Prénom du prof',
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
              IntlPhoneField(
                showDropdownIcon: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        color: AppColors.secondaryColor, width: 3.0),
                  ),
                ),
                languageCode: "fr",
                onChanged: (number) {
                  _inputPhoneChange(
                      number.number, number, number.countryISOCode);
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
        ));

    return !isSmallScreen
        ?
        //Large Screen
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
                              text: 'Professeurs',
                              icon: Icons.person_3,
                              tap: const ManageProf()));
                        }),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 250,
                            child: Image(
                                image: AssetImage("assets/coursImage.jpg")),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Modifier les informations du professeur ",
                                      style: GoogleFonts.poppins(
                                          color: AppColors.primaryColor,
                                          fontSize: FontSize.medium,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  editProfForm
                                ],
                              ),
                            ))
                      ],
                    )
                  ]),
            ),
          )
        :
        //Small screen
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
                            text: 'Professeurs',
                            icon: Icons.person_3,
                            tap: const ManageProf()));
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 200,
                    child: Image(image: AssetImage("assets/coursImage.jpg")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Modifier les informations du professeur ",
                      style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 15),
                  editProfForm
                ],
              ),
            ),
          );
  }
}
