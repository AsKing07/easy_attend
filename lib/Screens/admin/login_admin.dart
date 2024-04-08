import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Config/utils.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:easy_attend/Screens/admin/signup_admin.dart';
import 'package:easy_attend/Screens/changePassword.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body:
            //Si on est sur appareil mobile
            !screenSize().isWeb()
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
                    child: Center(
                        child: SingleChildScrollView(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Allons-y!",
                          style: GoogleFonts.poppins(
                              color: AppColors.textColor,
                              fontSize: FontSize.xxLarge,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            "Connectez-vous à votre compte admin!",
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
                              children: [
                                const Center(
                                  child: Text(
                                    "Section Administrateur",
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
                                      if (_emailController.text.isEmpty ||
                                          !value!.contains('@')) {
                                        return "Veuillez entrer un email valide";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    decoration: InputDecoration(
                                      labelText: 'Adresse Email',
                                      prefixIcon: const Icon(Icons.email),
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
                                            color: Color(0xff9DD1F1),
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
                                    obscureText: true,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColor),
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      labelText: "Mot de passe",
                                      prefixIcon: const Icon(Icons.password),
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
                                            color: Color(0xff9DD1F1),
                                            width: 3.0),
                                      ),
                                    )),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: GestureDetector(
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
                                            decoration:
                                                TextDecoration.underline),
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
                                      await auth_methods_admin().logAdminIn(
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
                                "Pas encore de compte ? ",
                                style: GoogleFonts.poppins(
                                    color: AppColors.textColor,
                                    fontSize: FontSize.medium,
                                    fontWeight: FontWeight.w600),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpAdmin(),
                                      ));
                                },
                                child: Text(
                                  "Inscrivez-vous",
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
                    ))))
                :
                //Si on est sur Ordinateur

                Center(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Allons-y!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: AppColors.textColor,
                              fontSize: FontSize.xxLarge,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            "Connectez-vous à votre compte admin!",
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
                              children: [
                                const Center(
                                  child: Text(
                                    "Section Administrateur",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor,
                                        fontSize: FontSize.xLarge,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth:
                                            400), // Définir la largeur maximale
                                    child: Column(
                                      children: [
                                        //Email
                                        TextFormField(
                                            controller: _emailController,
                                            validator: (value) {
                                              if (_emailController
                                                      .text.isEmpty ||
                                                  !value!.contains('@')) {
                                                return "Veuillez entrer un email valide";
                                              }
                                              return null;
                                            },
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: GoogleFonts.poppins(
                                                color: AppColors.textColor),
                                            decoration: InputDecoration(
                                              labelText: 'Adresse Email',
                                              prefixIcon:
                                                  const Icon(Icons.email),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10),
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
                                                    color: Color(0xff9DD1F1),
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
                                            obscureText: true,
                                            style: GoogleFonts.poppins(
                                                color: AppColors.textColor),
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            decoration: InputDecoration(
                                              labelText: "Mot de passe",
                                              prefixIcon:
                                                  const Icon(Icons.password),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 10),
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
                                                    color: Color(0xff9DD1F1),
                                                    width: 3.0),
                                              ),
                                            )),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: GestureDetector(
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
                                                    color: AppColors
                                                        .secondaryColor,
                                                    fontSize: FontSize.medium,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        GFButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await auth_methods_admin()
                                                  .logAdminIn(
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
                                          shape: GFButtonShape.pills,
                                          fullWidthButton: true,
                                        ),

                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Pas encore de compte ? ",
                                                style: GoogleFonts.poppins(
                                                    color: AppColors.textColor,
                                                    fontSize: FontSize.medium,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SignUpAdmin(),
                                                      ));
                                                },
                                                child: Text(
                                                  "Inscrivez-vous",
                                                  style: GoogleFonts.poppins(
                                                      color: AppColors
                                                          .secondaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          FontSize.medium),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                              ],
                            )),
                      ],
                    )),
                  ));
  }
}
