import 'package:flutter/material.dart';
import 'package:easy_attend/Methods/get_data.dart';
import 'package:easy_attend/Methods/set_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_attend/Models/Etudiant.dart';
import 'package:easy_attend/Models/Filiere.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';

class EditStudentPage extends StatefulWidget {
  final String studentId;

  EditStudentPage({required this.studentId});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  var _selectedNiveau;
  Filiere? _selectedFiliere;

  List<Filiere> Allfilieres = [];

  void loadStudentData() async {
    DocumentSnapshot etudiant =
        await get_Data().getStudentById(widget.studentId, context);

    if (etudiant.exists) {
      final data = etudiant.data() as Map<String, dynamic>;
      _nomController.text = data['nom'];
      _prenomController.text = data['prenom'];
      _phoneController.text = data['phone'];
      _matriculeController.text = data['matricule'];
    }
  }

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
    loadStudentData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Editer l\'étudiant',
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
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Modification d'un étudiant",
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
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await set_Data().modifierEtudiantByAdmin(
                              widget.studentId,
                              _nomController.text,
                              _prenomController.text,
                              _phoneController.text,
                              _selectedFiliere!.nomFiliere,
                              _selectedFiliere!.idDoc,
                              _selectedNiveau,
                              _matriculeController.text,
                              context);
                        }
                      },
                      child: Text("Modifier Etudiant",
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryColor,
                            fontSize: FontSize.medium,
                            fontWeight: FontWeight.bold,
                          )),
                    )
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
