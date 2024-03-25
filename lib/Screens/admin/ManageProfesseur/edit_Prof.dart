import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfPage extends StatefulWidget {
  final String profId;

  EditProfPage({required this.profId});

  @override
  State<EditProfPage> createState() => _EditProfPageState();
}

class _EditProfPageState extends State<EditProfPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  void loadProfData() async {
    DocumentSnapshot prof =
        await get_Data().getProfById(widget.profId, context);

    if (prof.exists) {
      final data = prof.data() as Map<String, dynamic>;

      _nomController.text = data['nom'];
      _prenomController.text = data['prenom'];
      _phoneController.text = data['phone'];
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Editer le professeur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return WarningWidget(
                          title: "Information",
                          content:
                              "Pour toute modification des informations sensibles(Email, Mot de passe), l'utilisateur concerné devra les modifier lui même depuis son compte",
                          height: 200);
                    });
              },
              icon: const Icon(Icons.info)),
        ],
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
                          if (_nomController.text.isEmpty ||
                              _nomController.text == null) {
                            return "Ce champ est obligatoire";
                          }
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
                                color: Color(0xff9DD1F1), width: 3.0),
                          ),
                        )),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                        controller: _prenomController,
                        validator: (value) {
                          if (_phoneController.text.isEmpty ||
                              _phoneController.text == null) {
                            return "Ce champ est obligatoire";
                          }
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
                                color: Color(0xff9DD1F1), width: 3.0),
                          ),
                        )),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                        controller: _phoneController,
                        validator: (value) {
                          if (_phoneController.text.isEmpty ||
                              _phoneController.text == null) {
                            return "Ce champ est obligatoire";
                          }
                        },
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(color: AppColors.textColor),
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: const Icon(Icons.phone),
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
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await set_Data().modifierProfByAdmin(
                              widget.profId,
                              _nomController.text,
                              _prenomController.text,
                              _phoneController.text,
                              context);
                        }
                      },
                      child: const Text('Modifier le professseur'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
