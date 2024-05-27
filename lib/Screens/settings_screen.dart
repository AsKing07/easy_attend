// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:convert';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Widgets/settings_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config/utils.dart';

class SettingsScreen extends StatefulWidget {
  String nom;
  SettingsScreen({super.key, required this.nom});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var utilisateur;

  String name = "";
  String email = "";
  final auth = FirebaseAuth.instance;
  Future<void> _loadUserName() async {
    // http.Response response = await http.get(
    //   Uri.parse('$BACKEND_URL/api/${widget.nom.toLowerCase()}/${user!.uid}'),
    // );
    // if (response.statusCode == 200 && response.body.isNotEmpty) {
    //   Map<String, dynamic> user = jsonDecode(response.body);
    //   setState(() {
    //     name = '${user['nom']}  ${user['prenom']}';
    //   });
    // } else {
    //   setState(() {
    //     name = widget.nom;
    //   });
    // }
    final prefs = await SharedPreferences.getInstance();
    var user = json.decode(prefs.getString('user')!);

    setState(() {
      name = '${user['nom']}  ${user['prenom']}';
      email = '${user['email']}';
      utilisateur = user;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: screenSize().isPhone(context)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              const Text(
                'Paramètres',
                style: TextStyle(
                    fontSize: 30.0,
                    letterSpacing: 2.0,
                    color: AppColors.secondaryColor),
              ),
              const SizedBox(height: 16.0),
              Text(
                widget.nom,
                style: const TextStyle(
                    fontSize: 30.0,
                    letterSpacing: 2.0,
                    color: AppColors.secondaryColor),
              ),
              const SizedBox(height: 16.0),
              Text(
                name,
                style: const TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 2.0,
                    color: AppColors.textColor),
              ),
              Text(
                email,
                style: const TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 2.0,
                    color: AppColors.textColor),
              ),
              const SizedBox(height: 100.0),
              SettingsTile(
                color: AppColors.secondaryColor,
                icon: Icons.lock,
                title: 'Changer le mot de passe',
                onTap: () {
                  auth
                      .sendPasswordResetEmail(email: utilisateur['email'])
                      .then((value) {
                    GFToast.showToast(
                        'Un e-mail de réinitialisation a été envoyé à votre adresse e-mail. Consultez également vos spams.',
                        context,
                        toastDuration: 6);
                  }).onError((error, stackTrace) {
                    GFToast.showToast(error.toString(), context,
                        toastDuration: 15);
                  });
                },
              ),
              const SizedBox(height: 40.0),
              SettingsTile(
                color: AppColors.secondaryColor,
                icon: Icons.person,
                title: 'Editer vos informations',
                onTap: () {},
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
