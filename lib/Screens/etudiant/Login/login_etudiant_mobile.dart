import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/changePassword.dart';
import 'package:easy_attend/Screens/professeur/profMethods/auth_methods_prof.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../etudiantMethods/connexion_methods_etudiant.dart';

class LoginEtudiantMobile extends StatefulWidget {
  const LoginEtudiantMobile({super.key});

  @override
  State<LoginEtudiantMobile> createState() => _LoginEtudiantMobileState();
}

class _LoginEtudiantMobileState extends State<LoginEtudiantMobile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5), // Opacité de 0.7 (70%),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Allons-y!",
                    style: GoogleFonts.poppins(
                        color: AppColors.textColor,
                        fontSize: FontSize.xxLarge,
                        fontWeight: FontWeight.w600),
                  ),
                  SvgPicture.asset(
                    'assets/students.svg',
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      "Bon Retour! Veuillez entrez vos informations de connexion",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppColors.secondaryColor,
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              "Connexion Etudiant",
                              style: TextStyle(
                                  color: AppColors.secondaryColor,
                                  fontSize: FontSize.xLarge,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          //Email
                          TextFormField(
                              controller: _emailController,
                              validator: (value) {
                                if (!value!.contains('@')) {
                                  return "Veuillez entrer un email valide";
                                }
                                if (_emailController.text.isEmpty) {
                                  return "Ce champ est requis";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textColor),
                              decoration: InputDecoration(
                                labelText: 'Adresse Email*',
                                prefixIcon: const Icon(Icons.email),
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
                              )),
                          const SizedBox(
                            height: 16,
                          ),

                          //Champ Password
                          TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Ce champ est obligatoire";
                                }
                                return null;
                              },
                              obscureText: !_passwordVisible,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textColor),
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "Mot de passe*",
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.shadow,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
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
                              )),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ChangePassword()));
                                },
                                child: Text(
                                  "Mot de passe oublié?",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.secondaryColor,
                                    fontSize: FontSize.medium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          GFButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await auth_methods_etudiant().logStudentIn(
                                    _emailController.text,
                                    _passwordController.text,
                                    context);
                              }
                            },
                            text: "Connexion",
                            textStyle: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.bold,
                            ),
                            color: AppColors.secondaryColor,
                            shape: GFButtonShape.pills,
                            fullWidthButton: true,
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pas de compte ? ",
                          style: GoogleFonts.poppins(
                              color: AppColors.textColor,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                          onTap: () {
                            auth_methods_prof().requestProfAccount(context);
                          },
                          child: Text(
                            "Inscrivez-vous",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: AppColors.secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: FontSize.medium),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
    ));
  }
}
