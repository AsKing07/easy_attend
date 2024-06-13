// ignore_for_file: use_build_context_synchronously, camel_case_types, unused_catch_clause, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/professeur/ProfHome.dart';
import 'package:easy_attend/Widgets/helper.dart';
import 'package:easy_attend/Widgets/my_warning_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class auth_methods_prof {
  final BACKEND_URL = dotenv.env['API_URL'];

  Future logProfIn(String email, String password, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.secondaryColor, size: 100)));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = FirebaseAuth.instance.currentUser!.uid;
      http.Response response = await http.get(
        Uri.parse('$BACKEND_URL/api/prof/getProfById/$uid'),
      );

      Map<String, dynamic> prof = jsonDecode(response.body);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        if (prof["statut"] == "0") {
          Navigator.pop(context);

          Helper().ErrorMessage(context,
              content:
                  "Désolé, vous n'êtes pas autorisé(e) à accéder à cette page.");
          FirebaseAuth.instance.signOut();
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("loggedIn", true);
          prefs.setString("role", "prof");

          prefs.setString("user", json.encode(prof));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ProfHome()));
        }
      } else {
        Navigator.pop(context);

        Helper().ErrorMessage(context,
            content:
                "Désolé, vous n'êtes pas autorisé(e) à accéder à cette page.");
        FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      Navigator.pop(context);
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          Helper().ErrorMessage(context,
              content: "Veuillez vérifier vos informations de connexion.");
        } else {
          Helper().ErrorMessage(context);
        }
      } else if (e is SocketException) {
        Helper().ErrorMessage(context,
            content: "Oups... veuillez vérifiez votre connexion internet");
      } else {
        Helper().ErrorMessage(context);
      }
    }
  }

  void requestProfAccount(BuildContext context) {
    //Remplacer plus tard par effectuer une requette lorsque la logique des requette sera coder

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
