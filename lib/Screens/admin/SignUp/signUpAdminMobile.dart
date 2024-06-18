import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/Login/login_admin.dart';
import 'package:easy_attend/Screens/admin/adminMethods/auth_methods_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class SignUpAdminMobile extends StatefulWidget {
  const SignUpAdminMobile({super.key});

  @override
  State<SignUpAdminMobile> createState() => _SignUpAdminMobileState();
}

class _SignUpAdminMobileState extends State<SignUpAdminMobile> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminPinController = TextEditingController();

  bool _passwordVisible = false;
  bool _passwordVisible2 = false;
  bool _passwordVisible3 = false;

  void _inputPhoneChange(
      String number, PhoneNumber internationlizedPhoneNumber, String isoCode) {
    setState(() {
      _phoneController.text = internationlizedPhoneNumber.completeNumber;
    });
  }

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
                      "Bienvenue sur EasyAttend! Veuillez compléter le formulaire pour finaliser votre inscription",
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
                          TextFormField(
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            controller: _nomController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Entrez votre nom *",
                              prefixIcon: const Icon(Icons.perm_identity),
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
                                return 'S\'il vous plaît entrez votre nom';
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
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            decoration: InputDecoration(
                              labelText: "Entrez votre prénom *",
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
                                return 'S\'il vous plaît entrez votre prénom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
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
                                labelText: 'Adresse Email *',
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
                            height: 15,
                          ),
                          IntlPhoneField(
                            showDropdownIcon: false,
                            countries: const [
                              Country(
                                name: "Benin",
                                nameTranslations: {
                                  "sk": "Benin",
                                  "se": "Benin",
                                  "pl": "Benin",
                                  "no": "Benin",
                                  "ja": "ベナン",
                                  "it": "Benin",
                                  "zh": "贝宁",
                                  "nl": "Benin",
                                  "de": "Benin",
                                  "fr": "Bénin",
                                  "es": "Benín",
                                  "en": "Benin",
                                  "pt_BR": "Benin",
                                  "sr-Cyrl": "Бенин",
                                  "sr-Latn": "Benin",
                                  "zh_TW": "貝南",
                                  "tr": "Benin",
                                  "ro": "Benin",
                                  "ar": "بنين",
                                  "fa": "بنين",
                                  "yue": "貝寧"
                                },
                                flag: "🇧🇯",
                                code: "BJ",
                                dialCode: "229",
                                minLength: 8,
                                maxLength: 8,
                              ),
                            ],
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
                            onSaved: (number) {
                              _inputPhoneChange(number!.number, number,
                                  number.countryISOCode);
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty ||
                                    value == "" ||
                                    value.length < 6) {
                                  return 'Entrez un mot de passe de 6 caractères au moins';
                                }
                                return null;
                              },
                              obscureText: !_passwordVisible,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textColor),
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "Mot de passe *",
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
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.text,
                            obscureText: !_passwordVisible2,
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            decoration: InputDecoration(
                              labelText: "Confirmez le mot de passe *",
                              prefixIcon: const Icon(Icons.password),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.shadow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible2 = !_passwordVisible2;
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
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Ce champ est obligatoire";
                              }
                              return null;
                            },
                            obscureText: !_passwordVisible3,
                            controller: _adminPinController,
                            keyboardType: TextInputType.number,
                            style:
                                GoogleFonts.poppins(color: AppColors.textColor),
                            decoration: InputDecoration(
                              labelText: "Code PIN des admin *",
                              prefixIcon: const Icon(Icons.pin),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible3
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.shadow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible3 = !_passwordVisible3;
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
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          GFButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // if (!PhoneNumber.fromCompleteNumber(
                                //         completeNumber:
                                //             _phoneController.text)
                                //     .isValidNumber())
                                //     {
                                //   Helper().ErrorMessage(context,
                                //       content:
                                //           'S\'il vous plaît entrez votre numéro valide');
                                //   ;
                                // }

                                FirebaseFirestore.instance
                                    .collection('pins')
                                    .doc("adminPin")
                                    .get()
                                    .then(
                                        (DocumentSnapshot<Map<String, dynamic>>
                                            snapshot) async {
                                  if (_adminPinController.text !=
                                      snapshot.data()?['pin']) {
                                    GFToast.showToast(
                                        'Le pin admin n\'est pas correcte. Veuillez vous rapprocher d\'un admin',
                                        context,
                                        backgroundColor: Colors.white,
                                        textStyle:
                                            const TextStyle(color: Colors.red),
                                        toastDuration: 8);
                                  } else {
                                    await auth_methods_admin().signUp(
                                        _emailController.text,
                                        _passwordController.text,
                                        _nomController.text,
                                        _prenomController.text,
                                        _phoneController.text,
                                        context);
                                  }
                                });
                              }
                            },
                            text: "S'inscrire",
                            textStyle: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: FontSize.medium,
                              fontWeight: FontWeight.bold,
                            ),
                            color: AppColors.secondaryColor,
                            shape: GFButtonShape.pills,
                            fullWidthButton: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Vous avez déjà un compte ? ",
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textColor,
                                      fontSize: FontSize.medium,
                                      fontWeight: FontWeight.w600),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginAdmin()));
                                  },
                                  child: Text(
                                    "Connectez-vous!",
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
                      ))
                ],
              ),
            )),
      ),
    ));
  }
}
