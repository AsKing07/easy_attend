// ignore_for_file: camel_case_types, file_names

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class addNewProfPage extends StatefulWidget {
  final Function() callback;

  const addNewProfPage({super.key, required this.callback});

  @override
  State<addNewProfPage> createState() => _addNewProfPageState();
}

class _addNewProfPageState extends State<addNewProfPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Ajouter un nouveau prof',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: !screenSize().isWeb()
          //App mobile
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
                      "Création de professeur",
                      style: GoogleFonts.poppins(
                          color: AppColors.textColor,
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        "Entrez les informations du professeur",
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
                          //Nom du prof
                          TextFormField(
                            controller: _nomController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Entrez le nom du prof",
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                              labelText: "Entrez votre prénom",
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Entrez Email",
                              prefixIcon: const Icon(Icons.email_outlined),
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                              if (value!.isEmpty || !value.contains('@')) {
                                return 'S\'il vous plâit entrez l\'email';
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                          TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Mot de passe ",
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                              if (value!.isEmpty ||
                                  value == "" ||
                                  value.length < 6) {
                                return 'Entrez un mot de passe de 6 caractères au moins';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirmez le mot de passe",
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
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
                                    color: Color(0xff9DD1F1), width: 3.0),
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
                              if (value!.isEmpty || value.length < 6) {
                                return 'Entrez un mot de passe de 6 caractères au moins';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne sont pas identiques';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          GFButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await auth_methods_admin().createProf(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nomController.text,
                                    _prenomController.text,
                                    _phoneController.text,
                                    context);
                                widget.callback();
                              }
                            },
                            text: "Ajouter Professeur",
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
//Web View
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
                      "Création de professeur",
                      style: GoogleFonts.poppins(
                          color: AppColors.textColor,
                          fontSize: FontSize.xxLarge,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        "Entrez les informations du professeur",
                        style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Nom du prof
                              TextFormField(
                                controller: _nomController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Entrez le nom du prof",
                                  prefixIcon: const Icon(Icons.person_outlined),
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                                  labelText: "Entrez votre prénom",
                                  prefixIcon: const Icon(Icons.person_outlined),
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: "Entrez Email",
                                  prefixIcon: const Icon(Icons.email_outlined),
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'S\'il vous plâit entrez l\'email';
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                              TextFormField(
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Mot de passe ",
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                                  if (value!.isEmpty ||
                                      value == "" ||
                                      value.length < 6) {
                                    return 'Entrez un mot de passe de 6 caractères au moins';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                controller: _confirmPasswordController,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Confirmez le mot de passe",
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
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
                                        color: Color(0xff9DD1F1), width: 3.0),
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
                                  if (value!.isEmpty || value.length < 6) {
                                    return 'Entrez un mot de passe de 6 caractères au moins';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Les mots de passe ne sont pas identiques';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              GFButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await auth_methods_admin().createProf(
                                        _emailController.text,
                                        _passwordController.text,
                                        _nomController.text,
                                        _prenomController.text,
                                        _phoneController.text,
                                        context);
                                    widget.callback();
                                  }
                                },
                                text: "Ajouter Professeur",
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
            ),
    );
  }
}
