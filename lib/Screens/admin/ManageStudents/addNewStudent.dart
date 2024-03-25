// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Screens/admin/adminMethods/connexion_methods_admin.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class addNewStudentPage extends StatefulWidget {
  const addNewStudentPage({super.key});

  @override
  State<addNewStudentPage> createState() => _addNewStudentPageState();
}

class _addNewStudentPageState extends State<addNewStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _selectedNiveau;
  Filiere? _selectedFiliere;

  List<Filiere> Allfilieres = [];

  Future<void> loadAllActifFilieres() async {
    List<QueryDocumentSnapshot> docsFiliere =
        await get_Data().getActifFiliereData();
    List<Filiere> fil = [];

    docsFiliere.forEach((doc) {
      Filiere filiere = Filiere(
        idDoc: doc.id,
        nomFiliere: doc["nomFiliere"],
        idFiliere: doc["idFiliere"],
        statut: doc["statut"],
        niveaux: List<String>.from(
          doc['niveaux'],
        ),
      );

      fil.add(filiere);
    });

    setState(() {
      Allfilieres.addAll(fil);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    loadAllActifFilieres();
    super.initState();
  }

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
          'Ajouter un nouvel étudiant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.medium,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Création d'un étudiant",
              style: GoogleFonts.poppins(
                  color: AppColors.textColor,
                  fontSize: FontSize.xxLarge,
                  fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "Entrez les informations de l'étudiant",
                style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: FontSize.medium,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _matriculeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Entrez le matricule",
                      prefixIcon: const Icon(Icons.numbers),
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
                        return 'S\'il vous plaît entrez le matricule';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _nomController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Entrez le nom",
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
                      labelText: "Entrez le prénom",
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
                      if (value!.isEmpty ||
                          !value.contains('@') ||
                          value == null) {
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
                      prefixIcon: const Icon(Icons.contact_phone_outlined),
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
                  //Dropdown Filieres
                  DropdownButtonFormField<Filiere>(
                    validator: (value) {
                      if (value == null) {
                        return "Ce champ est obligatoire";
                      } else {
                        return null;
                      }
                    },
                    value: _selectedFiliere,
                    elevation: 18,
                    onChanged: (Filiere? value) {
                      setState(() {
                        _selectedFiliere = value!;
                      });
                    },
                    items: Allfilieres.map<DropdownMenuItem<Filiere>>(
                        (Filiere value) {
                      return DropdownMenuItem<Filiere>(
                        value: value,
                        child: Text(value.nomFiliere),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                        labelText: 'Choisissez la filière'),
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  //Dropdown Niveaux
                  DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == null) {
                        return "Ce champ est obligatoire";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (String? value) {
                      setState(() {
                        _selectedNiveau = value!;
                      });
                    },
                    items: _selectedFiliere?.niveaux
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    hint: const Text('Choisissez le niveau'),
                  ),
                  const SizedBox(
                    height: 16,
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
                      if (value!.isEmpty || value == "" || value.length < 6) {
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
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Etudiant etu = Etudiant(
                            matricule: _matriculeController.text,
                            nom: _nomController.text,
                            prenom: _prenomController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            phone: _phoneController.text,
                            idFiliere: _selectedFiliere!.idDoc,
                            filiere: _selectedFiliere!.nomFiliere,
                            niveau: _selectedNiveau,
                            statut: "1");

                        await connexion_methods_admin()
                            .addOneStudent(etu, context);
                      }
                    },
                    child: Text("Ajouter Etudiant",
                        style: GoogleFonts.poppins(
                          color: AppColors.secondaryColor,
                          fontSize: FontSize.medium,
                          fontWeight: FontWeight.bold,
                        )),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
