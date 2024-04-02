import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/login_admin.dart';
import 'package:easy_attend/Screens/admin/signup_admin.dart';
import 'package:easy_attend/Screens/etudiant/login_etudiant.dart';
import 'package:easy_attend/Screens/professeur/login_prof.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _pinController = TextEditingController();
  String _selectedRole = 'Administrateur';
  String _selectedSchool = 'Selectionner une école';

  List<String> _schools = [];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

//Charger les écoles
  Future<void> _loadSchools() async {
    final snapshot = await FirebaseFirestore.instance.collection('pins').get();
    final List<String> schools = [];
    for (var doc in snapshot.docs) {
      schools.add(doc.id);
      print(doc);
    }
    setState(() {
      _schools = schools;
      // Ajouter 'Selectionner une école' à la liste des écoles
      _schools.insert(0, 'Selectionner une école');
      _schools.remove('adminPin');
    });
  }

  void _validateAndRedirect() {
    if (_selectedSchool.isEmpty ||
        _selectedSchool == "Selectionner une école") {
      GFToast.showToast('Vous devez au moins sélectionner une école', context,
          backgroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.red),
          toastDuration: 3);
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
        case 'Étudiant':
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginStudent()));
          break;
        default:
          GFToast.showToast('Vous devez au moins sélectionner un rôle', context,
              backgroundColor: Colors.white,
              textStyle: const TextStyle(color: Colors.red),
              toastDuration: 3);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentification')),
      body: Container(
        color: AppColors.backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      labelText: 'Choisissez votre école'),
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  items: <String>['Administrateur', 'Professeur', 'Étudiant']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  decoration:
                      const InputDecoration(labelText: 'Choisissez votre rôle'),
                ),
                const SizedBox(height: 32.0),
                GFButton(
                  onPressed: _validateAndRedirect,
                  text: "Valider",
                  shape: GFButtonShape.pills,
                  fullWidthButton: true,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
