import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/Login/login_admin.dart';
import 'package:easy_attend/Screens/etudiant/Login/login_etudiant.dart';
import 'package:easy_attend/Screens/professeur/Login/login_prof.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AuthPageMobile extends StatefulWidget {
  const AuthPageMobile({super.key});

  @override
  State<AuthPageMobile> createState() => _AuthPageMobileState();
}

class _AuthPageMobileState extends State<AuthPageMobile> {
  String _selectedRole = 'Administrateur';
  String _selectedSchool = 'Selectionner une école';

  List<String> _schools = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    final snapshot = await FirebaseFirestore.instance.collection('pins').get();
    final List<String> schools = [];
    for (var doc in snapshot.docs) {
      schools.add(doc.id);
    }
    setState(() {
      _schools = schools;
      _schools.insert(0, 'Selectionner une école');
      _schools.remove('adminPin');
    });
  }

  void _validateAndRedirect() {
    if (_selectedSchool.isEmpty ||
        _selectedSchool == "Selectionner une école") {
      GFToast.showToast(
          "Vous devez au moins sélectionner une école",
          backgroundColor: AppColors.redColor,
          context,
          toastDuration: 6);
    } else {
      switch (_selectedRole) {
        case 'Administrateur':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginAdmin()));
          break;
        case 'Professeur':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginProf()));
          break;
        case 'Etudiant':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginStudent()));
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous devez au moins sélectionner un rôle'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   backgroundColor: AppColors.tertiaryColor,
      //   title: const Text(
      //     'Authentification',
      //     style: TextStyle(color: AppColors.white),
      //   ),
      //   centerTitle: true,
      // ),
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Bienvenue sur EasyAttend !",
                  style: TextStyle(
                    fontSize: FontSize.xxLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              const Image(
                image: AssetImage("assets/easyattend.png"),
                height: 200, // Taille adéquate à l'image
              ),
              const Text(
                'Veuillez sélectionner votre école et votre rôle.',
                style: TextStyle(
                    fontSize: FontSize.large, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSchool,
                      onChanged: (String? value) {
                        if (value != 'Selectionner une école') {
                          setState(() {
                            _selectedSchool = value!;
                          });
                        }
                      },
                      items: _schools
                          .map<DropdownMenuItem<String>>(
                            (String school) => DropdownMenuItem<String>(
                              value: school,
                              child: Text(school),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Choisissez votre école',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      items: <String>[
                        'Administrateur',
                        'Professeur',
                        //if (!screenSize().isWeb() && screenSize().isAndroid())
                        'Etudiant'
                      ]
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Choisissez votre rôle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    GFButton(
                      color: AppColors.secondaryColor,
                      onPressed: _validateAndRedirect,
                      text: "Continuer",
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
