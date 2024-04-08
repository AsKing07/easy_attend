// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Widgets/settings_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import '../../Config/utils.dart';

class SettingsScreen extends StatefulWidget {
  String nom;
  SettingsScreen({super.key, required this.nom});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String name = "";
  final auth = FirebaseAuth.instance;
  Future<void> _loadUserName() async {
    final DocumentSnapshot x = await FirebaseFirestore.instance
        .collection(widget.nom.toLowerCase())
        .doc(user!.uid)
        .get();
    setState(() {
      if (x.exists) {
        name = '${x['nom']}  ${x['prenom']}';
      } else {
        name = widget.nom;
      }
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
              const SizedBox(height: 100.0),
              SettingsTile(
                color: const Color(0xFF080121), //Color(0xFF03010a),
                icon: Icons.lock,
                title: 'Changer le mot de passe',
                onTap: () {
                  auth
                      .sendPasswordResetEmail(email: auth.currentUser!.email!)
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
                color: const Color(0xFF080121), //Color(0xFF03010a),
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
