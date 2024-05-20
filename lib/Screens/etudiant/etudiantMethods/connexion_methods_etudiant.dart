// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, unused_catch_clause, camel_case_types

import 'dart:convert';
import 'dart:io';

import 'package:easy_attend/Screens/etudiant/EtudiantHome.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Config/styles.dart';

class auth_methods_etudiant {
  final BACKEND_URL = dotenv.env['API_URL'];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future logStudentIn(
      String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.secondaryColor, size: 100),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      if (uid != null) {
        http.Response response = await http.get(
          Uri.parse('$BACKEND_URL/api/student/getStudentById/$uid'),
        );

        Map<String, dynamic> student = jsonDecode(response.body);

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          if (student["statut"] == "0") {
            Navigator.pop(context);

            Helper().notAuthorizedMessage(context);
            FirebaseAuth.instance.signOut();
          } else {
            final SharedPreferences prefs = await _prefs;
            prefs.setBool("loggedIn", true);
            prefs.setString("role", "student");

            prefs.setString("user", json.encode(student));

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const EtudiantHome()));
          }
        } else {
          Navigator.pop(context);

          Helper().notAuthorizedMessage(context);
          FirebaseAuth.instance.signOut();
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (e is FirebaseAuthException) {
        print(e.code);
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          Helper().badCredential(context);
        } else {
          Helper().ErrorMessage(context);
        }
      } else if (e is SocketException) {
        Helper().networkErrorMessage(context);
      } else {
        Helper().ErrorMessage(context);
      }
    }
  }

  void requestProfAccount(BuildContext context) {
    //Remplacer plus tard par effectuer une requette lorsque la logique des requette sera codée

    showDialog(
      context: context,
      builder: (context) {
        return WarningWidget(
          title: "Demande",
          content: "Contactez un admin pour votre inscription",
          height: 140,
        );
      },
    );
  }
}
