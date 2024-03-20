import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/adminMethods/connexion_methods_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class SignUpAdmin extends StatefulWidget {
  const SignUpAdmin({super.key});

  @override
  State<SignUpAdmin> createState() => _SignUpAdminState();
}

class _SignUpAdminState extends State<SignUpAdmin> {
  final _formKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminPinController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              height: 200,
              child: const Stack(
                children: [
                  Positioned(
                      top: 100,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "INSCRIPTION ADMIN",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 26),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Inscrivez-vous pour continuer",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17),
                          )
                        ],
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Entrez votre nom",
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Entrez votre Email",
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
                            if (value!.isEmpty ||
                                !value.contains('@') ||
                                value == null) {
                              return 'S\'il vous plâit entrez votre email';
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
                            labelText: "Entrez votre numéro",
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
                              return 'S\'il vous plâit entrez votre numéro valide';
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
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                              print(_passwordController.text);
                              print(value);
                              print(_confirmPasswordController.text);
                              // GFToast.showToast(
                              //     'Les mots de passes ne sont pas identiques',
                              //     context,
                              //     backgroundColor: Colors.white,
                              //     textStyle: const TextStyle(color: Colors.red),
                              //     toastDuration: 3);
                              return 'Les mots de passe ne sont pas identiques';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          obscureText: true,
                          controller: _adminPinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Code PIN des admin",
                            prefixIcon: const Icon(Icons.pin),
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
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              FirebaseFirestore.instance
                                  .collection('pins')
                                  .doc("adminPin")
                                  .get()
                                  .then((DocumentSnapshot<Map<String, dynamic>>
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
                                  await connexion_methods_admin().signUp(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "INSCRIPTION",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
